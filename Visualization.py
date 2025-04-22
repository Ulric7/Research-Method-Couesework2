import streamlit as st
from streamlit_echarts import st_echarts
import pandas as pd

st.set_page_config(page_title="Dietary and environmental influences", layout="wide")
st.title("Dietary Types and Environmental Impacts - A Multi-Category Comparison")

# retrieve data
df = pd.read_csv("dataset/data_cleaned.csv")

# Sidebar: Multiple selection of gender and age groups
all_genders = df["sex"].unique().tolist()
all_ages = df["age_group"].unique().tolist()

selected_genders = st.sidebar.multiselect("Select gender", all_genders, default=all_genders)
selected_ages = st.sidebar.multiselect("Select Age Group", all_ages, default=all_ages)

# Filtering data
filtered_df = df[df["sex"].isin(selected_genders) & df["age_group"].isin(selected_ages)]

# Display Forms
st.subheader("Filtered data")
st.dataframe(filtered_df)

# Radar chart preparation
st.subheader("Comparison of average values of environmental indicators (radar chart)")
radar_metrics = [
    "mean_ghgs", "mean_land", "mean_watscar", "mean_eut",
    "mean_bio", "mean_watuse", "mean_acid", "total_env_impact"
]

from streamlit_echarts import st_echarts

# Environmental indicator fields
radar_metrics = [
    "mean_ghgs", "mean_land", "mean_watscar", "mean_eut",
    "mean_bio", "mean_watuse", "mean_acid", "total_env_impact"
]

# Constructing axes indicator (to get maximum values from filtered data)
indicators = []
for col in radar_metrics:
    max_val = filtered_df[col].max() + 0.05
    name = col.replace("mean_", "").replace("_", " ").title()
    indicators.append({"name": name, "max": round(max_val, 3)})

# series data
series_data = []
for (sex, age), group in filtered_df.groupby(["sex", "age_group"]):
    avg = group[radar_metrics].mean().tolist()
    series_data.append({
        "value": [round(v, 4) for v in avg],
        "name": f"{sex.title()} {age}",
        "areaStyle": {"opacity": 0.3}
    })

# ECharts option
option = {
    "title": {
        "text": "Radar chart of environmental impacts by gender + age group",
        "left": "center",
        "textStyle": {
            "color": "#ffffff",
            "fontSize": 22,
            "fontWeight": "bold"
        }
    },
    "tooltip": {"trigger": "item"},
    "legend": {
        "data": [item["name"] for item in series_data],
        "bottom": 0,
        "textStyle": {
            "color": "#cccccc",
            "fontSize": 14
        },
        "type": "scroll"
    },
    "radar": {
        "indicator": indicators,
        "name": {
            "textStyle": {
                "color": "#eeeeee",
                "fontSize": 13
            }
        }
    },
    "series": [{
        "type": "radar",
        "emphasis": {"lineStyle": {"width": 4}},
        "data": series_data
    }]
}


# Show charts
st.subheader("🌈 Environmental impact radar map (support mouse hover highlighting)")
st_echarts(options=option, height="600px")

