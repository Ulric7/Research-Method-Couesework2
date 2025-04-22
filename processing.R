rm(list = ls())
# Load library
library(dplyr)

# Load the data
setwd('C:/资料/文件/Research Method/CW2/dataset')
data <- read.csv("Results_21Mar2022.csv")

#Select data
vegan_data <- data %>%
  filter(diet_group == "vegan") %>%
  select(sex, age_group, mean_ghgs, mean_land, mean_watscar, mean_eut, mean_bio, mean_watuse, mean_acid)

library(scales)
env_vars <- c("mean_ghgs", "mean_land", "mean_watscar","mean_eut", "mean_bio", "mean_watuse", "mean_acid")

vegan_data[env_vars] <- lapply(vegan_data[env_vars], rescale)

vegan_data$total_env_impact <- rowMeans(vegan_data[env_vars])

vegan_summary <- vegan_data %>%
  group_by(sex, age_group) %>%
  summarise(across(all_of(c(env_vars, "total_env_impact")), mean), .groups = "drop")

data_cleaned <- vegan_summary
write.csv(data_cleaned, "data_cleaned.csv", row.names = FALSE)

#View(vegan_summary)


library(fmsb)

# Select the 4 groups you want to compare
radar_data <- vegan_summary %>%
  filter((sex == "female" & age_group %in% c("20-29", "60-69")) |
           (sex == "male" & age_group %in% c("20-29", "60-69"))) %>%
  select(mean_ghgs, mean_land, mean_watscar, mean_eut, mean_bio, mean_watuse, mean_acid)



# Add the first line: maximum value
radar_max <- rep(0.42, ncol(radar_data))

# Add second line: minimum value
radar_min <- rep(0.2, ncol(radar_data))

# Consolidation of data
radar_plot_data <- rbind(radar_max, radar_min, radar_data)

# Setting the line name (optional)
rownames(radar_plot_data) <- c("Max", "Min", 
                               "F-20-29", "F-60-69", "M-20-29", "M-60-69")

# Setting colours
colors_border <- c("red", "pink", "blue", "skyblue")
colors_in <- adjustcolor(colors_border, alpha.f = 0.2)
colnames(radar_plot_data) <- c("GHG", "Land", "WaterScar", "Eutro", "Biodiv", "WaterUse", "Acid")


# Radargram main function
radarchart(radar_plot_data,
           axistype = 1,
           pcol = colors_border,         # thread colour
           pfcol = colors_in,            # fill colour
           plwd = 2,                     # line width
           plty = 1,                     # linear
           cglcol = "grey",              # Grid line colour
           cglty = 1,
           axislabcol = "black",
           caxislabels = seq(0.2, 0.45, 0.05),
           vlcex = 1.2                   # Variable Label Font Size
)

# Add Legend
legend(x = 1.1, y = 1.3,
       legend = rownames(radar_plot_data)[3:6],
       bty = "n", pch = 20, col = colors_border,
       text.col = "black", cex = 0.9, pt.cex = 1.5)













