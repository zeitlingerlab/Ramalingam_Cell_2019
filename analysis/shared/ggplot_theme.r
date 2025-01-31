library(grid)

theme_manuscript <- function(base_size=18) {
  # adapted from ggplot2bdc theme_bdc_simple()
  theme_bw(base_size=base_size) %+replace%
  theme(line = element_line(colour = "black", size = 0.5, linetype = 1, lineend = "square"),
        rect = element_rect(fill = "white", colour = "black", size = 0.5, linetype = 1),
        #text = element_text(family = "", face = "plain", colour = "black", size = base_size,
        #                    hjust = 0.5, vjust = 0.5, angle = 0, lineheight = 0.9), 
        title = element_text(family = "", face = "bold", colour = "black", vjust = 0, 
                             hjust = 0.5, angle = 0),
        plot.background = element_rect(fill = "transparent", colour = NA),
        plot.title = element_text(size = rel(1.2), vjust = 0.8),
        plot.margin = unit(c(1, 1, 1, 1), "lines"), 
        panel.background = element_rect(fill = "white", colour = NA), 
        panel.border = element_rect(fill = "transparent", colour = NA), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.margin = unit(0.5, "lines"), 
        strip.background = element_rect(fill = "grey80", colour = NA),
        strip.text = element_text(size = rel(0.8)), 
        strip.text.x = element_text(), 
        strip.text.y = element_text(angle = -90), 
        axis.text = element_text(size = rel(0.8), margin = margin(0.1, unit="cm")),
        axis.line.x = element_line(size = 0.5, colour = "black"), 
        axis.line.y = element_line(size = 0.5, colour = "black"), 
        axis.text.x = element_text(),
        axis.text.y = element_text(), 
        axis.title.x = element_text(),
        axis.title.y = element_text(angle = 90), 
        axis.ticks = element_line(size = 0.5),
        axis.ticks.length = unit(0.15, "cm"),
        legend.background = element_blank(),
        legend.margin = unit(0, "cm"),
        legend.key = element_rect(fill = "transparent", color = NA),
        legend.key.size = unit(0.5, "lines"), 
        legend.key.height = unit(0.5, "lines"),
        legend.key.width = unit(0.7, "lines"),
        legend.text = element_text(size = rel(0.7), colour = "black"),
        legend.text.align = 0.5,
        legend.title = element_text(size = rel(0.7)), 
        legend.title.align = 0,
        legend.position = "top",
        legend.direction = "horizontal", 
        legend.justification = "center",
        legend.box = "horizontal")
}
