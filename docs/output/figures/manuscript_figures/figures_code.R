# Load necessary libraries
library(tidyverse)
library(here)
library(lubridate)
library(patchwork)
library(ggrepel)
library(viridis)
library(sf)

# Figure 3 - map
data_file <- file.path(here("data", "sdis", "raw", "sdis_raw.csv"))
sdis_data <- read_csv(data_file)

## Three-Panel Policy Map: Horizontal Layout
remotes::install_github("UrbanInstitute/urbnmapr")
library(urbnmapr)

# Create FOIA availability column
sdis_data <- sdis_data %>%
  mutate(
    foia_availability = case_when(
      state %in% c("California", "Florida", "Indiana", "Maine", 
                   "Nevada", "South Dakota", "Texas") ~ "provided",
      TRUE ~ "not_provided"
    )
  )

# Load US map data with proper AK/HI positioning
us_map_data <- get_urbn_map("states", sf = TRUE)

# Prepare map data
sdis_data_map <- sdis_data %>%
  mutate(region = tolower(state))

us_map_data <- us_map_data %>%
  mutate(region = tolower(state_name))

# Merge polygon data with policy data
map_data_repos <- us_map_data %>%
  left_join(sdis_data_map, by = "region")

# Function to create individual maps
create_policy_map <- function(fill_var, fill_title, fill_colors, plot_title) {
  ggplot(map_data_repos) +
    geom_sf(aes(fill = !!sym(fill_var)), color = "white", linewidth = 0.3) +
    scale_fill_manual(
      name = fill_title,
      values = fill_colors,
      na.value = "gray90",
      na.translate = FALSE,
      guide = guide_legend(
        direction = "vertical",
        title.position = "top",
        title.hjust = 0.5
      )
    ) +
    theme_void() +
    labs(title = plot_title) +
    theme(
      plot.title = element_text(size = 40, face = "bold", hjust = 0.5, margin = margin(b = 5)),
      legend.position = "bottom",
      legend.title = element_text(size = 1, face = "bold"),
      legend.text = element_text(size = 35),
      legend.box = "vertical",
      legend.margin = margin(t = 5, b = 0)
    )
}

# Create the three maps
map_arrestee_repos <- create_policy_map(
  "arrestee_collection", " ",
  c("yes" = "#31688e", "no" = "#666666"), 
  "A. Arrestee DNA Collection Policy"
)

map_familial_repos <- create_policy_map(
  "fam_search", " ",
  c("permitted" = "#31688e", "prohibited" = "#fde724", "unspecified" = "#666666"),
  "B. Familial Search Policy"
)

map_foia_repos <- create_policy_map(
  "foia_availability", " ",
  c("provided" = "#31688e", "not_provided" = "#666666"),
  "C. FOIA Response Status"
)

# Combine maps horizontally
figure_combined <- map_arrestee_repos | map_familial_repos | map_foia_repos

figure_combined + plot_annotation(
  title = " ",
  theme = theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))
)

ggsave("data/manuscript_figures/fig3_maps.png", plot = figure_combined, width = 10, height = 6)

# Figure 5 - anomaly log

data_file <- file.path(here("data", "ndis", "intermediate", "anomaly_log.csv"))
anomaly_log <- read_csv(data_file)

### Set metric and anomaly type ordering for consistent display
metric_order <- c("Offender Profiles", "Forensic Profiles", "Arrestee Profiles", 
                  "Investigations Aided", "NDIS Labs")
anomaly_type_order <- c("spike_dip", "cont_spike_dip", "zero_error", "cont_zero_error", "osc_lag")

# Prepare data for plot
anomaly_plot_data <- anomaly_log %>%
  group_by(metric, jurisdiction) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(metric = factor(metric, levels = metric_order))

# Custom colors matching scheme
metric_colors <- c(
  "Offender Profiles"    = "#31688e",
  "Arrestee Profiles"    = "#35b779",
  "Forensic Profiles"    = "#440154",
  "Investigations Aided" = "#c00000",
  "NDIS Labs"            = "#fde724"
)

# Create stacked bar plot
p_anomaly_distribution <- ggplot(anomaly_plot_data, 
                                aes(x = jurisdiction, y = count, fill = metric)) +
  geom_bar(stat = "identity", position = "stack", color = "black", 
           linewidth = 0.3, width = 1) +
  scale_fill_manual(name = "Metric", values = metric_colors) +
  scale_y_continuous(limits = c(0, NA), expand = c(0, 0)) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.4),
    axis.ticks = element_line(color = "black", linewidth = 0.4),
    axis.text = element_text(color = "black", size = 26),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title.x = element_text(size = 30, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 30, face = "bold", margin = margin(t = 15)),
    axis.title = element_text(size = 30, face = "bold"),
    legend.title = element_text(size = 30, face = "bold"),
    legend.text = element_text(size = 30),
    legend.key.size = unit(0.5, "cm"),
    legend.key.width = unit(0.4, "cm"),
    legend.key.height = unit(0.4, "cm"),
    aspect.ratio = 0.65
  ) +
  labs(
    title = " ",
    x = "Jurisdiction",
    y = "Number of Anomalies"
  )

p_anomaly_distribution

ggsave("data/manuscript_figures/fig5_anomaly_log.png", plot = p_anomaly_distribution, width = 10, height = 6)

# Figure 6 - Heatmap raw vs clean

data_file <- file.path(here("data", "ndis", "intermediate", "ndis_intermediate.csv"))
ndis_intermediate <- read_csv(data_file)

# Heatmap
temporal_coverage_intermediate <-  ndis_intermediate %>%
  mutate(year = year(capture_datetime)) %>%
  count(jurisdiction, year) %>%
  complete(jurisdiction, year = 2001:2025, fill = list(n = 0)) %>%
  filter(!is.na(jurisdiction)) %>%
  mutate(jurisdiction = factor(jurisdiction, levels = rev(sort(unique(jurisdiction)))))

heatmap_raw <- ggplot(temporal_coverage_intermediate, aes(x = year, y = jurisdiction, fill = n)) +
  geom_tile(color = "white", linewidth = 0.3) +
  scale_fill_viridis(
    name = "Snapshots\nper Year",
    option = "plasma",
    direction = -1,
    breaks = c(0, 12, 24, 48),
    labels = c("0", "12", "24", "48+")
  ) +
  scale_x_continuous(
    breaks = seq(2001, 2025, by = 1),
    expand = expansion(mult = 0.01)
  ) +
  labs(
    x = NULL,
    y = "Jurisdiction",
    title = "A) Raw Snapshots Dataset",
  ) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 0.75, size = 25),
    axis.text.y = element_text(size = 25),
    plot.title = element_text(size = 30, hjust = 0),
    legend.position = "none",
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 30, margin = margin(r = 26))
  )

heatmap_raw

# Prepare data for heatmap - CLEANED DATASET

data_file_clean <- file.path(here("data", "ndis", "final", "NDIS_time_series.csv"))
ndis_clean <- read_csv(data_file_clean)

temporal_coverage_clean <- ndis_clean %>%
  mutate(year = year(capture_datetime)) %>%
  count(jurisdiction, year) %>%
  complete(jurisdiction, year = 2001:2025, fill = list(n = 0)) %>%
  filter(!is.na(jurisdiction)) %>%
  mutate(jurisdiction = factor(jurisdiction, levels = rev(sort(unique(jurisdiction)))))

# Create the heatmap for cleaned data
heatmap_after_clean <- ggplot(temporal_coverage_clean, aes(x = year, y = jurisdiction, fill = n)) +
  geom_tile(color = "white", linewidth = 0.3) +
  scale_fill_viridis(
    name = "Snapshots per Year",
    option = "plasma",
    direction = -1,
    breaks = c(0, 12, 24, 48),
    labels = c("0", "12", "24", "48+")
  ) +
  scale_x_continuous(
    breaks = seq(2001, 2025, by = 1),
    expand = expansion(mult = 0.01)
  ) +
  labs(
    x = NULL,
    y = NULL,
    title = "B) Cleaned Snapshots Dataset"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 0.75, size = 25),
    axis.text.y = element_blank(),
    plot.title = element_text(size = 30, hjust = 0),
    legend.position = "right",
    legend.key.height = unit(0.6, "cm"), 
    legend.key.width = unit(0.2, "cm"), 
    legend.text = element_text(size = 30),
    legend.title = element_text(size = 30, margin = margin(b = 4)),
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
  )

heatmap_after_clean

# Combine heatmaps side by side
figure_heatmaps <- heatmap_raw + heatmap_after_clean + 
  plot_annotation(
    title = " ",
    theme = theme(plot.title = element_text(face = "bold", hjust = 0.5))
  ) +
  plot_layout(widths = c(1, 1))

ggsave("data/manuscript_figures/fig6_heatmap_raw_clean.png", plot = figure_heatmaps, width = 10, height = 6)

# Figure 7 - Data validation plot

# Preparation of growth_data_yearly 
growth_data_yearly <- ndis_clean %>%
  mutate(year = year(capture_datetime)) %>%
  group_by(jurisdiction, year) %>%
  arrange(jurisdiction, capture_datetime) %>%
  mutate(
    selection_priority = case_when(
      year <= 2018 ~ arrestee,
      year > 2018 ~ offender_profiles
    )
  ) %>%
  slice_max(order_by = selection_priority, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  group_by(year) %>%
  summarise(
    offender_total = sum(offender_profiles, na.rm = TRUE),
    arrestee_total = sum(arrestee, na.rm = TRUE),
    forensic_total = sum(forensic_profiles, na.rm = TRUE),
    investigations_total = sum(investigations_aided, na.rm = TRUE),
    n_jurisdictions = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    total_profiles = offender_total + arrestee_total + forensic_total,
    date = as.Date(paste0(year, "-06-01"))
  )

# Prepare data for plotting DNA profiles
dna_data <- growth_data_yearly %>%
  select(date, offender_total, arrestee_total, forensic_total, total_profiles) %>%
  pivot_longer(
    cols = c(offender_total, arrestee_total, forensic_total, total_profiles),
    names_to = "variable",
    values_to = "count"
  ) %>%
  mutate(
    variable = case_when(
      variable == "offender_total" ~ "Offender",
      variable == "arrestee_total" ~ "Arrestee", 
      variable == "forensic_total" ~ "Forensic",
      variable == "total_profiles" ~ "Total"
    )
  )

# Prepare data for plotting investigations
investigations_data <- growth_data_yearly %>%
  select(date, investigations_total)

# Create literature dataset
literature_data <- tribble(
  ~citation, ~asof_date, ~offender_profiles, ~arrestee_profiles, ~forensic_profiles, ~total_profiles, ~investigations_aided, ~short_label,
  "FBI Brochure", "2000-12-01", 441181, NA, 21625, NA, 1573, "FBI (Dec 2000)",
  "FBI Brochure", "2002-12-01", 1247163, NA, 46177, NA, 6670, "FBI (Dec 2002)",
  "FBI Brochure", "2004-12-01", 2038514, NA, 93956, NA, 21266, "FBI (Dec 2004)",
  "FBI Brochure", "2006-12-01", 3977435, 54313, 160582, NA, 45364, "FBI (Dec 2006)",
  "FBI Brochure", "2008-12-01", 6399200, 140719, 248943, NA, 81955, "FBI (Dec 2008)",
  "FBI Brochure", "2010-12-01", 8564705, 668849, 351951, NA, 130317, "FBI (Dec 2010)",
  "FBI Brochure", "2012-12-01", 10086404, 1332721, 446689, NA, 190560, "FBI (Dec 2012)",
  "FBI Brochure", "2015-06-01", 11822927, 2028734, 638162, NA, 274648, "FBI (Jun 2015)",
  "Ge et al., 2012", "2011-06-01", NA, NA, NA, 10000000, 141300, "Ge et al., 2012",
  "Ge et al., 2014", "2013-05-01", NA, NA, NA, 12000000, 185000, "Ge et al., 2014",
  "Wickenheiser, 2022", "2021-10-01", 14836490, 4513955, 1144255, NA, 587773, "Wickenheiser, 2022",
  "Link et al., 2023", "2022-11-01", NA, NA, NA, 21791620, 622955, "Link et al., 2023",
  "Greenwald & Phiri, 2024", "2024-02-01", 17000000, 5000000, 1300000, NA, 680000, "Greenwald & Phiri, 2024"
) %>%
  mutate(
    asof_date = as.Date(asof_date),
    total_profiles = ifelse(
      is.na(total_profiles),
      rowSums(select(., offender_profiles, arrestee_profiles, forensic_profiles), na.rm = TRUE),
      total_profiles
    )
  )

# Prepare literature data for DNA profiles
literature_dna <- literature_data %>%
  select(short_label, asof_date, offender_profiles, arrestee_profiles, forensic_profiles, total_profiles) %>%
  pivot_longer(
    cols = c(offender_profiles, arrestee_profiles, forensic_profiles, total_profiles),
    names_to = "variable",
    values_to = "count"
  ) %>%
  filter(!is.na(count)) %>%
  mutate(
    variable = case_when(
      variable == "offender_profiles" ~ "Offender",
      variable == "arrestee_profiles" ~ "Arrestee",
      variable == "forensic_profiles" ~ "Forensic",
      variable == "total_profiles" ~ "Total"
    )
  )

# Prepare literature data for investigations
literature_investigations <- literature_data %>%
  select(short_label, asof_date, investigations_aided) %>%
  filter(!is.na(investigations_aided))

# Get date range
date_range <- range(growth_data_yearly$date)
extended_date_range <- c(min(date_range) - years(1), max(date_range))
legend_start_date <- extended_date_range[1]

# Calculate y-axis limits for DNA profiles
max_dna <- max(dna_data$count, na.rm = TRUE)
y_upper_dna <- max_dna * 1.05

# Calculate y-axis limits for investigations
max_inv <- max(investigations_data$investigations_total, na.rm = TRUE)
y_upper_inv <- max_inv * 1.05

# Define colors for each plot type
offender_color <- "#31688e"
arrestee_color <- "#35b779"
forensic_color <- "#440154"
total_color <- "#22a884"
investigations_color <- "#fde724"

# Create individual plots for each DNA profile type
p_offender <- ggplot() +
  geom_line(data = dna_data %>% filter(variable == "Offender"), 
            aes(x = date, y = count), 
            color = offender_color, linewidth = 0.5) +
  geom_point(data = dna_data %>% filter(variable == "Offender"), 
             aes(x = date, y = count), 
             color = offender_color, size = 1.0) +
  geom_point(data = literature_dna %>% filter(variable == "Offender"),
             aes(x = asof_date, y = count),
             shape = 4, size = 2.8, stroke = 1.0, color = offender_color) +
  geom_label_repel(
    data = literature_dna %>% filter(variable == "Offender" & lubridate::year(asof_date) < 2020),
    aes(x = asof_date, y = count, label = short_label),
    size = 45 / .pt,
    nudge_y = 5000000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  geom_label_repel(
    data = literature_dna %>% filter(variable == "Offender" & lubridate::year(asof_date) >= 2021),
    aes(x = asof_date, y = count, label = short_label),
    size = 45 / .pt,
    nudge_y = 1000000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  scale_x_date(name = "Year", date_breaks = "1 years", date_labels = "%Y",
               limits = extended_date_range, expand = expansion(mult = 0.02)) +
  scale_y_continuous(name = "Offender Profiles",
                     labels = function(x) ifelse(x >= 1e6, paste0(x/1e6, "M"), 
                                                  ifelse(x >= 1e3, paste0(x/1e3, "K"), x)),
                     limits = c(0, max(literature_dna %>% filter(variable == "Offender") %>% pull(count), na.rm = TRUE) * 1.1),
                     expand = expansion(mult = c(0, 0.05))) +
  theme_minimal(base_size = 35) +
  theme(
    panel.grid.major.y = element_line(color = "gray90", linewidth = 0.3),
    panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.3),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    axis.text = element_text(color = "black", size = 35),
    axis.text.x = element_text(angle = 45, hjust = 1, margin = margin(t = -5)),
    axis.text.y = element_text(margin = margin(r = -10)),
    axis.title = element_text(size = 35, face = "bold"),
    axis.title.x = element_blank(),
    axis.title.y = element_text(margin = margin(r = 2)),
    plot.title = element_blank(),
    plot.title.position = "plot"
  ) +
  labs(x = "Year", y = NULL, title = "Offender Profiles")

p_offender

p_arrestee <- ggplot() +
  geom_line(data = dna_data %>% filter(variable == "Arrestee"), 
            aes(x = date, y = count), 
            color = arrestee_color, linewidth = 0.5) +
  geom_point(data = dna_data %>% filter(variable == "Arrestee"), 
             aes(x = date, y = count), 
             color = arrestee_color, size = 1.0) +
  geom_point(data = literature_dna %>% filter(variable == "Arrestee"),
             aes(x = asof_date, y = count),
             shape = 4, size = 2.8, stroke = 1.0, color = arrestee_color) +
  geom_label_repel(
    data = literature_dna %>% filter(variable == "Arrestee"),
    aes(x = asof_date, y = count, label = short_label),
    size = 45 / .pt,
    nudge_y = 500000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  scale_x_date(name = "Year", date_breaks = "1 years", date_labels = "%Y",
               limits = extended_date_range, expand = expansion(mult = 0.02)) +
  scale_y_continuous(name = "Arrestee Profiles",
                     labels = function(x) ifelse(x >= 1e6, paste0(x/1e6, "M"), 
                                                  ifelse(x >= 1e3, paste0(x/1e3, "K"), x)),
                     limits = c(0, max(literature_dna %>% filter(variable == "Arrestee") %>% pull(count), na.rm = TRUE) * 1.1),
                     expand = expansion(mult = c(0, 0.05))) +
  theme_minimal(base_size = 35) +
  theme(
    panel.grid.major.y = element_line(color = "gray90", linewidth = 0.3),
    panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.3),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    axis.text = element_text(color = "black", size = 35),
    axis.text.x = element_text(angle = 45, hjust = 1, margin = margin(t = -5)),
    axis.text.y = element_text(margin = margin(r = -10)),
    axis.title = element_text(size = 35, face = "bold"),
    axis.title.x = element_blank(),
    axis.title.y = element_text(margin = margin(r = 2)),
    plot.title = element_blank(),
    plot.title.position = "plot") +
  labs(x = "Year", y = NULL, title = "Arrestee Profiles")

p_arrestee

p_forensic <- ggplot() +
  geom_line(data = dna_data %>% filter(variable == "Forensic"), 
            aes(x = date, y = count), 
            color = forensic_color, linewidth = 0.5) +
  geom_point(data = dna_data %>% filter(variable == "Forensic"), 
             aes(x = date, y = count), 
             color = forensic_color, size = 1.0) +
  geom_point(data = literature_dna %>% filter(variable == "Forensic"),
             aes(x = asof_date, y = count),
             shape = 4, size = 2.8, stroke = 1.0, color = forensic_color) +
  geom_label_repel(
    data = literature_dna %>% filter(variable == "Forensic" & lubridate::year(asof_date) < 2020),
    aes(x = asof_date, y = count, label = short_label),
    size = 45 / .pt,
    nudge_y = 500000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  geom_label_repel(
    data = literature_dna %>% filter(variable == "Forensic" & lubridate::year(asof_date) >= 2021),
    aes(x = asof_date, y = count, label = short_label),
    size = 45 / .pt,
    nudge_y = 100000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  scale_x_date(name = "Year", date_breaks = "1 years", date_labels = "%Y",
               limits = extended_date_range, expand = expansion(mult = 0.02)) +
  scale_y_continuous(name = "Forensic Profiles",
                     labels = function(x) ifelse(x >= 1e6, paste0(x/1e6, "M"), 
                                                  ifelse(x >= 1e3, paste0(x/1e3, "K"), x)),
                     limits = c(0, max(literature_dna %>% filter(variable == "Forensic") %>% pull(count), na.rm = TRUE) * 1.1),
                     expand = expansion(mult = c(0, 0.05))) +
  theme_minimal(base_size = 35) +
  theme(
    panel.grid.major.y = element_line(color = "gray90", linewidth = 0.3),
    panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.3),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    axis.text = element_text(color = "black", size = 35),
    axis.text.x = element_text(angle = 45, hjust = 1, margin = margin(t = -5)),
    axis.text.y = element_text(margin = margin(r = -10)),
    axis.title = element_text(size = 35, face = "bold"),
    axis.title.x = element_blank(),
    axis.title.y = element_text(margin = margin(r = 2)),
    plot.title = element_blank(),
    plot.title.position = "plot") +
  labs(x = "Year", y = NULL, title = "Forensic Profiles")

p_forensic

p_total <- ggplot() +
  geom_line(data = dna_data %>% filter(variable == "Total"), 
            aes(x = date, y = count), 
            color = total_color, linewidth = 0.5) +
  geom_point(data = dna_data %>% filter(variable == "Total"), 
             aes(x = date, y = count), 
             color = total_color, size = 1.0) +
  geom_point(data = literature_dna %>% filter(variable == "Total"),
             aes(x = asof_date, y = count),
             shape = 4, size = 2.8, stroke = 1.0, color = total_color) +
  geom_label_repel(
    data = literature_dna %>% filter(variable == "Total" & lubridate::year(asof_date) >= 2020),
    aes(x = asof_date, y = count, label = short_label),
    size = 45 / .pt,
    nudge_y = -1000000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "y", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  geom_label_repel(
    data = literature_dna %>% filter(variable == "Total" & lubridate::year(asof_date) < 2021),
    aes(x = asof_date, y = count, label = short_label),
    size = 45 / .pt,
    nudge_y = 6000000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  scale_x_date(name = "Year", date_breaks = "1 years", date_labels = "%Y",
               limits = extended_date_range, expand = expansion(mult = 0.02)) +
  scale_y_continuous(name = "Total Profiles",
                     labels = function(x) ifelse(x >= 1e6, paste0(x/1e6, "M"), 
                                                  ifelse(x >= 1e3, paste0(x/1e3, "K"), x)),
                     limits = c(0, max(literature_dna %>% filter(variable == "Total") %>% pull(count), na.rm = TRUE) * 1.1),
                     expand = expansion(mult = c(0, 0.05))) +
  theme_minimal(base_size = 35) +
  theme(
    panel.grid.major.y = element_line(color = "gray90", linewidth = 0.3),
    panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.3),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    axis.text = element_text(color = "black", size = 35),
    axis.text.x = element_text(angle = 45, hjust = 1, margin = margin(t = -5)),
    axis.text.y = element_text(margin = margin(r = -10)),
    axis.title = element_text(size = 35, face = "bold"),
    axis.title.x = element_blank(),
    axis.title.y = element_text(margin = margin(r = 2)),
    plot.title = element_blank(),
    plot.title.position = "plot" ) +
  labs(x = "Year", y = NULL, title = "Total Profiles")

p_total

p_investigations_grid <- ggplot() +
  geom_line(data = investigations_data, 
            aes(x = date, y = investigations_total), 
            color = investigations_color, linewidth = 0.5) +
  geom_point(data = investigations_data, 
             aes(x = date, y = investigations_total), 
             color = investigations_color, size = 1.0) +
  geom_point(data = literature_investigations,
             aes(x = asof_date, y = investigations_aided),
             shape = 4, size = 2.8, stroke = 1.0, color = investigations_color) +
  geom_label_repel(
    data = literature_investigations %>% filter(lubridate::year(asof_date) < 2021),
    aes(x = asof_date, y = investigations_aided, label = short_label),
    size = 45 / .pt,
    nudge_y = 100000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both", force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  geom_label_repel(
    data = literature_investigations %>% filter(lubridate::year(asof_date) > 2021),
    aes(x = asof_date, y = investigations_aided, label = short_label),
    size = 45 / .pt,
    nudge_x = -600,
    nudge_y = 15000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "x",
    force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  geom_label_repel(
    data = literature_investigations %>% filter(lubridate::year(asof_date) == 2021),
    aes(x = asof_date, y = investigations_aided, label = short_label),
    size = 45 / .pt,
    nudge_y = 10000,
    nudge_x = 1000,
    box.padding = 0.35, point.padding = 0.5,
    min.segment.length = 0.5, segment.color = "gray50",
    direction = "both",
    force = 5, force_pull = 1,
    max.overlaps = Inf,
    fill = "white", label.size = 0.2, label.padding = unit(0.15, "lines")
  ) +
  scale_x_date(name = "Year", date_breaks = "1 years", date_labels = "%Y",
               limits = extended_date_range, expand = expansion(mult = 0.02)) +
  scale_y_continuous(name = "Investigations Aided",
                     labels = function(x) ifelse(x >= 1e6, paste0(x/1e6, "M"), 
                                                  ifelse(x >= 1e3, paste0(x/1e3, "K"), x)),
                     limits = c(0, max(literature_investigations %>% pull(investigations_aided), na.rm = TRUE) * 1.1),
                     expand = expansion(mult = c(0, 0.05))) +
  theme_minimal(base_size = 35) +
  theme(
    panel.grid.major.y = element_line(color = "gray90", linewidth = 0.3),
    panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.3),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    axis.text = element_text(color = "black", size = 35),
    axis.text.x = element_text(angle = 45, margin = margin(t = -5)),
    axis.text.y = element_text(margin = margin(r = -10)),
    axis.title = element_text(size = 35, face = "bold"),
    axis.title.x = element_text(margin = margin(t = 2)),
    axis.title.y = element_text(margin = margin(r = 2)),
    plot.title = element_blank(),
    plot.title.position = "plot") +
  labs(x = "Year", y = NULL, title = "Investigations Aided")

p_investigations_grid

plots_grid <- (p_offender + p_arrestee) / 
              (p_forensic + p_total) / 
              (p_investigations_grid)

plots_grid <- plots_grid + 
  plot_layout(heights = c(1, 1, 1)) &
  theme(plot.title = element_text(size = 60, face = "bold"),
        axis.title = element_text(size = 60, face = "bold"),
        axis.text = element_text(size = 48))

# Save the combined grid
ggsave("data/manuscript_figures/fig7_verification_grid.png", 
       plot = plots_grid, 
       width = 20, 
       height = 18, 
       dpi = 300)
