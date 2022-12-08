#' Simulador de aclareos grafico con el modelo de Reineke (1933)
#'
#' La funcion permite simular aclareos de forma grafica utilizando el indice de densidad de Reineke (1933)
#'
#' @param x Objeto creado con la funcion \code{link{sim_aclareos_reineke}}
#'
#' @return Regresa una grafica con los resultados de la simulacion tabular de la funcion \code{link{sim_aclareos_reineke}}
#'
#' @seealso \code{\link{sim_aclareos_reineke}}
#'
#' @export
#'
#' @import ggplot2

plot_sim_aclareos_reineke <- function(x){

  if (names(x[1]) != "simulacion_reineke") {

    stop("El objeto que debe ingresar es el obtenido con la funcion 'sim_aclareos_reineke'")

  } else {

    # Datos del objeto del simulador tabular
    df <- x$simulacion_reineke
    IDR_max <- x$IDR_max
    IDR <- x$IDR
    IDRrel <- x$IDR_relativo
    B1 <- x$pendiente
    lim_autoaclareo <- x$lim_autoclareo
    lim_const <- x$lim_constante
    lim_libre <- x$lim_libre
    DCMR <- x$DCMR

    # Datos de la simulación
    DCM = df$DCM
    N = df$N

    df1 = data.frame(DCM, N)

    # Datos de limites
    df2 <- expand.grid(DCM = 1:max(df1$DCM)+10,
                       IDR = round(c(IDR_max,
                                     IDR_max*lim_autoaclareo,
                                     IDR_max*lim_const,
                                     IDR_max*lim_libre),0))

    df2$B1 <- B1; df2$N <- df2$IDR * (df2$DCM/DCMR)^df2$B1

    IDRs1 <- factor(df2$IDR)

    plot_sim <- ggplot2::ggplot(df2, ggplot2::aes(x = DCM, y = N, group = IDRs1)) +

      ggplot2::geom_line(ggplot2::aes(linetype = IDRs1, color = IDRs1), size =1.05) +

      ggplot2::scale_x_log10(breaks = seq(from = 0, to = 200, by = 10)) +

      ggplot2::scale_y_log10(breaks = c(0, 100, 500, 1000, 5000, 10000, 50000, 100000)) +

      ggplot2::labs(title = "",
           y = expression(bold("N"~(Arb~ ha^-1))),
           x = expression(bold("DCM"~(cm)))) +

      ggplot2::geom_step(df1, mapping = ggplot2::aes(DCM, N, group = F, linetype = "Aclareos", color = "Aclareos"),
                size = 1)  +

      ggplot2::geom_point(df1, mapping = ggplot2::aes(DCM, N, group = F, linetype = "Aclareos", color = "Aclareos"),
                 size=2.5) +

      ggplot2::scale_linetype_manual(values = c("solid", "solid", "solid", "solid", "dotted"),
                            breaks = c(levels(IDRs1), "Aclareos")) +

      ggplot2::scale_color_manual(values = c("blue", "green", "red", "black", "gray30"),
                         breaks = c(levels(IDRs1), "Aclareos")) +

      ggplot2::theme_bw() +

      ggplot2::theme(legend.position = "top",
            legend.title = ggplot2::element_blank(),
            legend.text = ggplot2::element_text(size = 12),
            legend.key.width = ggplot2::unit(1.5, "cm"),
            axis.text = ggplot2::element_text(color = "black", face = "plain", size = 11),
            axis.title = ggplot2::element_text(colour = "black", face = "bold", size = 13),
            panel.border = ggplot2::element_rect(colour="black", fill = NA, size = 0.5)
      )

  }


  return(plot_sim)

}
