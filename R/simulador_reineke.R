#' Simulador de aclareos tabular con el modelo de Reineke (1933)
#'
#' La funcion permite simular aclareos utilizando el indice de densidad de Reineke (1933)
#'
#' @param IDR_max Valor del indice de densidad maximo del sitio
#' @param N Numero de arboles presente en el rodal
#' @param DCM Diametro cuadratico medio (cm)
#' @param DCMR Diametro cuadratico medio de referencia (cm)
#' @param B1 Parametro de la pendiente de Reineke. Default -1.605
#' @param No.aclareos Numero de aclareos que se quieren simular. Default 3 aclareos
#' @param lim_autoclareo Limite inferior del autoaclareo. Default 0.7
#' @param lim_const Limite inferior del crecimiento constante. Default 0.4
#' @param lim_libre Limite inferior del crecimiento libre. Default 0.2
#'
#' @return Devuelve la simulacion de aclareos a partir de la condicion de un rodal
#' @export sim_aclareos_reineke

sim_aclareos_reineke <- function(IDR_max, N, DCM, DCMR = 25, B1 = -1.605,
                                 No.aclareos = 3, lim_autoclareo = 0.7,
                                 lim_const = 0.4, lim_libre = 0.2){

  as.numeric(IDR_max, DCMR, N, DCMR, B1, No.aclareos, lim_autoclareo, lim_const, lim_libre)

  # Límite del autoaclareo
  IDRsup <- round(IDR_max * lim_autoclareo, 0)

  # Límite inferior de la zona de crecimiento constante
  IDRinf <- round(IDR_max * lim_const, 0)

  # IDR del rodal
  IDR = round(N * (DCMR/DCM)^B1, 0)

  # IDR relativo
  IDRrel <- round(IDR/IDR_max, 2)

  if (IDR_max <= 0 | N <= 0 | DCM <= 0 | DCMR <= 0) {

    stop("Los valores de IDR_max, N, DCM o DCMR deben ser > 0")

  } else if(B1 >= 0) {

    stop("El valor de B1 debe ser negativo\n")

  } else if(IDRrel > 1){

    stop("El IDR relativo es mayor que el IDR_max establecido para el sitio, verificar los datos")

  } else if(lim_autoclareo >= 1 | lim_const >= 1 | lim_libre >= 1 | lim_autoclareo <= 0 | lim_const <= 0 | lim_libre <= 0){

    stop("Los limites del autoaclareo, crecimiento constante y crecimiento libre: > 0 y < 1")

  } else if(lim_autoclareo <= lim_const | lim_autoclareo <= lim_libre){

    stop("Los limites de crecimiento constante o libre deben ser menores que el limite de autoaclareo")

  } else if(lim_const <= lim_libre){

    stop("El limite de crecimiento libre debe ser menor que el limite de crecimiento constante")

  } else{


    # Nombre de las columnas y filas
    ncols <- c("Etapa", "DCM", "N", "IC")
    nrows <- No.aclareos * 2

    # Tabla con ceros
    df <- as.data.frame(matrix(rep(0, nrows * length(ncols)), nrow = nrows, ncol = length(ncols)))

    # Primera fila con valores ingresados por el usuario
    df[1,1:4] <- c(1, as.numeric(DCM), as.numeric(N), 0)

    # Simulación de aclareos (tabular)
    if (IDRrel > lim_autoclareo) {

      for (i in 1:nrows) {

        # 1° Columna con nombres de aclareos y crecimiento
        df[1+i,1] = ifelse(i %% 2 == 1, "Aclareo", "Crecimiento")

        # 3° Columna Número de árboles (Residuales): N
        df[1+i,3] = ifelse(i %% 2 == 1, IDRinf*(df[i,2]/DCMR)^B1, df[i,3])

        # 2° Columna Diámetro Cuadrático Medio (Actual y proyección): DCM
        df[1+i,2] = ifelse(i %% 2 == 1, df[i,2] , DCMR*(df[i,3]/IDRsup)^(1/B1))

        # 4° Columna Intensidad de Corta (IC %)
        df[1+i,4] = ifelse(i %% 2 == 1, round((df[i,3]-df[i+1,3])/df[i,3] * 100,1), 0)


        # Cosecha final
        df[nrows+1,1] = "Cosecha final"

        df[nrows+2,2] = df[i+1,2]

        df[nrows+2,3] = 0;  df[nrows+2,4] = 0

        # Condición inicial
        df[1,1] = "Condicion inicial"
        df[nrows+2,1] = "Fin"

      }

    } else {

      for (i in 1:nrows) {

        # 1° Columna con nombres de aclareos y crecimiento
        df[1+i,1] = ifelse(i %% 2 == 0, "Aclareo", "Crecimiento")

        # 3° Columna Número de árboles (Residuales): N
        df[1+i,3] = ifelse(i %% 2 == 0, IDRinf*(df[i,2]/DCMR)^B1, df[i,3])

        # 2° Columna Diámetro Cuadrático Medio (Actual y proyección): DCM
        df[1+i,2] = ifelse(i %% 2 == 0, df[i,2] , DCMR*(df[i,3]/IDRsup)^(1/B1))

        # 4° Columna Intensidad de Corta (IC %)
        df[1+i,4] = ifelse(i %% 2 == 0, round((df[i,3]-df[i+1,3])/df[i,3] * 100,1), 0)


        # Cosecha final
        df[nrows+2,1] = "Cosecha final"

        # Crecimiento de DCM en cosecha final
        df[nrows+2,2] = DCMR*(df[i+1,3]/IDRsup)^(1/B1)

        df[nrows+2,3] = df[i+1,3]

        # N de cosecha final
        df[nrows+3,2] = df[i+2,2]

        # Llenado con ceros en campos necesarios (finales)
        df[nrows+2,4] = 0 ;df[nrows+3,3] = 0;  df[nrows+3,4] = 0

        # Condición inicial
        df[1,1] = "Condicion inicial"
        df[nrows+3,1] = "Fin"

      }


    }


  }

  # Condición del rodal
  condicion <- ifelse(IDRrel > lim_autoclareo & IDRrel <= 1, "Mortalidad inminente",
                      ifelse(IDRrel > lim_const & IDRrel <= lim_autoclareo, "Crecimiento constante",
                             ifelse(IDRrel > lim_libre & IDRrel <= lim_const, "Crecimiento libre",
                                    "Inicio del crecimiento del rodal")))

  # Comentarios de salida
  comentario1 <- paste0("Tu rodal tiene un IDR de: ", IDR, " y un IDR relativo de: ", IDRrel,"\n")
  comentario2 <- paste0("Su condicion actual es: ", condicion, "\n")
  comentario3 <- ifelse(condicion == "Crecimiento libre" | condicion == "Inicio del crecimiento del rodal",
                        "Se recomienda que el rodal reclute mas arboles y/o aumente su tamano promedio (DCM)\n",
                        "Por lo tanto se recomienda aclareos\n")

  # Redondear decimales
  df[c(2,4)] <- round(df[c(2,4)], 2); df[3] <- round(df[3], 0)

  # Asignar los nombres de las columnas
  colnames(df) <- ncols

  # Resultados
  out <- list(mensaje = message(comentario1, comentario2, comentario3),
              simulacion_reineke = df,
              DCMR = DCMR,
              IDR_max = IDR_max,
              IDR = IDR,
              IDR_relativo = IDRrel,
              pendiente = B1,
              lim_autoclareo = lim_autoclareo,
              lim_constante = lim_const,
              lim_libre = lim_libre)

  # Salida
  return(out[2:10])

}
