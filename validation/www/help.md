## Welcome to Disturbance Validation

This tool helps you check and clean up maps of human-made disturbances on the landscape - things like roads, tailing ponds, and clearings. You can look at them on a satellite map, fix any mistakes in their labels, and check that every feature has been labelled correctly.

You don't need any technical or GIS background to use it. This guide walks you through everything step by step.

<center><img src="app.png" width="600"></center>

<hr>

### Before you start: what you'll need

- **A GeoPackage file** (a file ending in `.gpkg`). A single file that bundles together several map layers - in this case, the boundary of your study area, plus your linear and areal disturbance features.
- **(Optional) A CSV file of approved labels**, if you want to check that every feature has been given an acceptable "Industry" and "Disturbance" label. An example is linked at the bottom of this page.

If you don't have your own data yet, a sample GeoPackage and CSV are also linked at the bottom of this page, so you can try the tool out first.

<hr>

### Quick start

1. Go to the **View features** tab.
2. Upload your GeoPackage file.
3. Check that the three dropdown boxes point to the right layers (they're usually filled in automatically).
4. Click **Map features**.
5. Explore the map and tables, and fix any details that need editing.
6. Save your work - see "Saving your changes" further down this page. There are two different save buttons, and it's worth knowing what each one does.

<hr>

### Viewing and editing your data (View features tab)

**1. Upload data** - Click "Geopackage" and choose your `.gpkg` file.

**2. Select layers** - The app tries to guess which layer is your study area, which is your linear disturbances, and which is your areal disturbances. Double-check the three dropdowns and correct them if needed.

**3. View disturbances** - Click **Map features**. Your data will appear in the main panel, which has three tabs:

- **Map view** - an interactive satellite/topographic map. Use the control in the top-right corner to switch background imagery or turn layers on and off.
- **Attribute tables** - two tables listing every linear and every areal feature in your data, one above the other.
- **Help** — this page.

**Click any feature** - whether on the map or in a row of the Attribute tables - and it will light up in yellow in both places at once, and its details will appear in the "Linear attributes" or "Areal attributes" card on the right.

**4. Edit attributes** - Once a feature is selected, click directly on a value in its card on the right to change it. Click elsewhere to confirm the change.

<hr>

### Saving your changes

There are two different save buttons, and they do different things:

- **Save existing geopackage** - saves your edits into the working copy of the file that the app is using during this session. This is a good habit to click regularly as you work, but it does **not** put a file on your computer.
- **Save as new geopackage** - creates a brand-new `.gpkg` file with all your edits included, and downloads it to your computer. **Use this before you close the app** if you want to keep a copy of your work.

<hr>

### Checking your labels (Validate attributes tab)

This section checks that every feature's "Industry" and "Disturbance" labels match a list of values you consider acceptable.

**1. Upload reference file** - Upload a CSV file listing the approved combinations of labels. It needs three columns: `TYPE_FEATURE`, `TYPE_INDUSTRY`, and `TYPE_DISTURBANCE`. Then click **Validate attributes**.

Your results appear in three tabs:

- **Linear errors** - linear features whose labels don't match the approved list.
- **Areal errors** - the same, for areal (polygon) features.
- **Permitted values** - the full list of approved label combinations, for reference.

In the error tables, each row is checked in three ways, shown as `ok` or a message telling you what's wrong:
- does the **Industry** label match an approved value?
- does the **Disturbance** label match an approved value?
- does the **combination** of the two match an approved pairing?

**2. Edit & save corrections** - Click directly on an Industry or Disturbance value in the error tables to fix it. Once you're happy with your corrections, use the same two save buttons described above (**Save existing geopackage** / **Save as new geopackage**) to keep them.

<hr>

### What your GeoPackage needs to contain

Your `.gpkg` file should include three layers:

- **A study area layer** - a single polygon outlining the boundary of the area you're working in (e.g. a watershed or region).
- **A linear disturbances layer** - line features such as roads, trails, or seismic lines.
- **An areal disturbances layer** - polygon features such as well pads, clearings, or borrow pits.

Each feature in the linear and areal layers should have two text labels attached to it:
- **TYPE_INDUSTRY** - the industry responsible, e.g. *Mining*, *Transportation*.
- **TYPE_DISTURBANCE** - the type of disturbance, e.g. *Access Road*, *Drill Pad*.

<hr>

### Getting started with sample data

If you'd like to try the tool before using your own data, these are available on GitHub:

- A [demo GeoPackage](https://github.com/beaconsproject/disturbance_validation/tree/main/www) to explore how the tool works.
- A [template CSV of approved Industry and Disturbance labels](https://github.com/beaconsproject/disturbance_validation/blob/main/www/yg_industry_disturbance_types.csv), based on Yukon Government's standard values.

<hr>

### Quick glossary

- **GeoPackage (`.gpkg`)** - a single file format that can hold multiple map layers at once.
- **Layer** - one set of map features, e.g. all your linear disturbances.
- **Feature** - one individual item on the map, e.g. a single road segment or a single well pad.
- **Attribute** - a piece of information attached to a feature, like a label or category (shown in the tables and cards as columns).
