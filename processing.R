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

# 选择你要比较的4个群体
radar_data <- vegan_summary %>%
  filter((sex == "female" & age_group %in% c("20-29", "60-69")) |
           (sex == "male" & age_group %in% c("20-29", "60-69"))) %>%
  select(mean_ghgs, mean_land, mean_watscar, mean_eut, mean_bio, mean_watuse, mean_acid)



# 添加第一行：最大值
radar_max <- rep(0.42, ncol(radar_data))

# 添加第二行：最小值
radar_min <- rep(0.2, ncol(radar_data))

# 合并数据
radar_plot_data <- rbind(radar_max, radar_min, radar_data)

# 设置行名（可选）
rownames(radar_plot_data) <- c("Max", "Min", 
                               "F-20-29", "F-60-69", "M-20-29", "M-60-69")

# 设置颜色
colors_border <- c("red", "pink", "blue", "skyblue")
colors_in <- adjustcolor(colors_border, alpha.f = 0.2)
colnames(radar_plot_data) <- c("GHG", "Land", "WaterScar", "Eutro", "Biodiv", "WaterUse", "Acid")


# 雷达图主函数
radarchart(radar_plot_data,
           axistype = 1,
           pcol = colors_border,         # 线颜色
           pfcol = colors_in,            # 填充颜色
           plwd = 2,                     # 线宽
           plty = 1,                     # 线型
           cglcol = "grey",              # 网格线颜色
           cglty = 1,
           axislabcol = "black",
           caxislabels = seq(0.2, 0.45, 0.05),
           vlcex = 1.2                   # 变量标签字体大小
)

# 添加图例
legend(x = 1.1, y = 1.3,
       legend = rownames(radar_plot_data)[3:6],
       bty = "n", pch = 20, col = colors_border,
       text.col = "black", cex = 0.9, pt.cex = 1.5)













