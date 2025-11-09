# Font Size Audit for ndis_analysis.qmd

## Summary
The document has **inconsistent font sizing** across different plot types, ranging from tiny (base_size = 10) to enormous (base_size = 35 before fixes, legends with size = 20).

## Global Settings Applied

### YAML Header (lines 11-16)
```yaml
execute:
  echo: true
  warning: false
  freeze: auto
  fig-width: 10     # NEW: Default figure width
  fig-height: 7     # NEW: Default figure height
```

### Custom Theme Function (added after line 112)
```r
theme_ndis <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      axis.text = element_text(color = "black", size = base_size),
      axis.title = element_text(size = base_size + 1, face = "bold"),
      plot.title = element_text(face = "bold", size = base_size + 3, hjust = 0),
      plot.subtitle = element_text(size = base_size + 2, hjust = 0),
      legend.text = element_text(size = base_size - 1),
      legend.title = element_text(size = base_size, face = "bold"),
      legend.key.size = unit(0.5, "cm"),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank()
    )
}
```

## Detailed Font Size Inventory

### 1. Raw Data Visualization Plots (Lines 373-386, 1912-1925)
**Current Settings:**
- `theme_minimal(base_size = 10)` ❌ TOO SMALL
- `axis.text.x = element_text(..., size = 15)` ⚠️ INCONSISTENT
- `axis.text.y = element_text(size = 15)` ⚠️ INCONSISTENT
- `plot.title = element_text(..., size = 20)` ⚠️ TOO LARGE
- `plot.subtitle = element_text(size = 18)` ⚠️ TOO LARGE
- `legend.text = element_text(size = 15)` ⚠️ INCONSISTENT
- `legend.title = element_text(size = 18)` ⚠️ TOO LARGE
- `axis.title.x = element_text(size = 18, ...)` ⚠️ TOO LARGE
- `axis.title.y = element_text(size = 18, ...)` ⚠️ TOO LARGE

**Recommended:** Replace with `theme_ndis()` or `theme_ndis(base_size = 12)`

### 2. Correction Plots (Lines 1240-1254, 1547-1561)
**Current Settings:**
- `theme_minimal(base_size = 11)` ✅ REASONABLE (but could use theme_ndis)
- `axis.text = element_text(..., size = 12)` ✅ REASONABLE
- `axis.title.x = element_text(size = 20, ...)` ❌ TOO LARGE
- `axis.title.y = element_text(size = 20, ...)` ❌ TOO LARGE
- `axis.title = element_text(size = 18, ...)` ⚠️ CONFLICTING with above
- `legend.title = element_text(size = 20, ...)` ❌ TOO LARGE
- `legend.text = element_text(size = 15)` ⚠️ SLIGHTLY LARGE
- `legend.key.size = unit(0.5, "cm")` ✅ OK

**Recommended:** Replace entire theme() block with `theme_ndis(base_size = 11)` + any plot-specific adjustments

### 3. Heatmap Coverage Plot (Lines 1812-1823)
**Current Settings:**
- `theme_minimal(base_size = 11)` ✅ REASONABLE
- `axis.text = element_text(..., size = 16)` ⚠️ LARGER THAN BASE
- `axis.title = element_text(size = 20, ...)` ❌ TOO LARGE
- Additional annotations with `size = 6` ✅ OK for annotations

**Recommended:** Use `theme_ndis(base_size = 12)` + keep annotation sizes

### 4. Peer-Review Comparison Plots (Lines 2101-2360)
**Current Settings (RECENTLY FIXED):**
- `theme_minimal(base_size = 12)` ✅ GOOD
- `axis.text = element_text(..., size = 12)` ✅ GOOD
- `axis.title = element_text(size = 12, ...)` ✅ GOOD
- `geom_label_repel(size = 3.5, ...)` ✅ GOOD (was 45 / .pt before)
- Combined plot theme:
  - `plot.title = element_text(size = 18, ...)` ✅ GOOD
  - `axis.title = element_text(size = 18, ...)` ✅ GOOD
  - `axis.text = element_text(size = 14)` ✅ GOOD

**Recommended:** This section is GOOD but could benefit from using `theme_ndis(base_size = 12)` for consistency

### 5. Plotly Interactive Plots (Various lines)
**Current Settings:**
- `marker = list(size = 6-12, ...)` ✅ OK (plotly uses different sizing)
- `titlefont = list(size = 12)` ✅ OK
- `tickfont = list(size = 10)` ✅ OK

**Recommended:** No changes needed (plotly sizing is independent)

### 6. Flextable (Line 324)
**Current Settings:**
- `fontsize(size = 10, part = "all")` ✅ OK (table font size is appropriate)

**Recommended:** No changes needed

## Priority Action Items

### HIGH PRIORITY - Font sizes causing visual issues:
1. **Lines 373-386, 1912-1925**: Replace with `theme_ndis()` - legends and titles too large
2. **Lines 1240-1254, 1547-1561**: Replace axis.title sizes (20→12), legend.title (20→12)
3. **Lines 1812-1823**: Replace axis.title size (20→12)

### MEDIUM PRIORITY - Standardization:
4. Apply `theme_ndis()` consistently across all plots for maintainability
5. Remove redundant theme() specifications after base theme is set

### LOW PRIORITY - Optional improvements:
6. Consider chunk-specific fig-width/fig-height for plots that need it
7. Document theme_ndis() usage in comments

## Recommended Font Size Standards

For 10x7 inch figures (new default):
- **Base size**: 11-12 pt
- **Axis text**: base_size (11-12)
- **Axis titles**: base_size + 1 (12-13)
- **Plot titles**: base_size + 3 (14-15)
- **Plot subtitles**: base_size + 2 (13-14)
- **Legend text**: base_size - 1 (10-11)
- **Legend title**: base_size (11-12)
- **Geom labels**: 3-4 ggplot2 units
- **Annotations**: 5-7 ggplot2 units (smaller than labels)

## Implementation Strategy

1. ✅ **DONE**: Add global fig-width and fig-height to YAML
2. ✅ **DONE**: Create theme_ndis() function
3. **TODO**: Systematically replace theme_minimal() + theme() blocks with theme_ndis()
4. **TODO**: Test render after each section to ensure no regressions
5. **TODO**: Remove redundant size specifications after theme application

## Files Modified
- `/Users/tlasisi/GitHub/PODFRIDGE-Databases/qmd_root/ndis_analysis.qmd`
  - Added fig-width: 10, fig-height: 7 to YAML
  - Added theme_ndis() function after package loading
  - Previously fixed peer-review comparison plots (base_size 35→12, labels 45/.pt→3.5)
