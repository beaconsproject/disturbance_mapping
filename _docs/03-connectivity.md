# Connectivity Mapping

General tasks to discuss and integrate under the objectives below:

- Engage partners / collaborators
- Organize and implement scoping / planning workshops

## Assess current state of ecological connectivity

### Protected and conserved area connectivity

The overall goal is to evaluate the connectivity of existing and/or proposed PCA networks.  The features of interest are PCAs and the PCA networks, but some species-level information is also needed to run the analysis i.e., dispersal distance of generic species. The permeability of the matrix also needs to be taken into consideration.  Specific objectives include:

1. Evaluate the ecological connectivity of existing and proposed PCA networks
2. Quantify and rank the contribution of individual existing or proposed sites (PAs, IPCAs, BAs) to network connectivity (this includes extensions to existing PCAs)
3. Assess the sensitivity of network connectivity to assumptions about dispersal capability and matrix permeability
4. Identify and prioritize areas of high landscape integrity between PCAs that can serve as corridors or stepping stones (climate change)
5. Develop a shiny app to visualize the effects of i) adding/removing individual PCAs and ii) changing assumptions about dispersal/permeability on network connectivity

**Datasets:**

- Intactness layer - to be developed in conjunction with the Disturbance Mapping project. See also “Terrestrial ecosystem connectivity” section
- Land cover e.g. NALC 2015, ESRI land cover 2020
- High-resolution annual forest land cover maps for Canada’s forested ecosystems (1984-2019)
- Ecozones and ecoregions; major drainage areas
- [Canadian Protected and Conserved Areas Database - Canada.ca](https://www.canada.ca/en/environment-climate-change/services/national-wildlife-areas/protected-conserved-areas-database.html)

**Tools:**

- R Makurhini package (calculates numerous relevant metrics)
- GrapHab (graph-based methods)

**Tasks:**

- Define a planning region based on e.g., ecozones, drainage areas, KDTT with buffer, or northern Y2Y region
- Acquire datasets (ecoregions, protected areas, land cover, etc.) and create a database with common extent, resolution, and projection
- Work in conjunction with Disturbance Mapping project to create/acquire cumulative disturbance and intactness datasets
- Define parameters for generic species (e.g., minimum patch sizes, median dispersal distances) based on literature review and indigenous knowledge
- Prepare resistance surface using land cover and/or footprint map
    - Review previous work on defining resistance values
- Select connectivity metrics (see Keeley et al. 2021 and references listed within and below)
- Perform connectivity analysis
    - Review recent papers on protected area connectivity
    - Develop procedures for conducting all required analyses
    - Run analyses
- Summarize outputs of connectivity analyses
    - Prepare summary tables, plots and maps
    - Develop shiny app to visualize sensitivity of results to assumptions and PCA inclusions

**References:**

- Saura et al. 2017, Ward et al. 2020

### Terrestrial ecosystem connectivity

The overall goal is to evaluate landscape connectivity as well as connectivity of specific habitat or ecosystem types e.g., old forests, shrublands, grasslands, wetlands. Species-level information could be used if we assume that certain habitat types could be linked to species, in which case we could use dispersal distances to measure effective distance between patches. The permeability of the matrix also needs to be taken into consideration. Specific objectives include:

- Evaluate landscape connectivity
- Evaluate connectivity of specific habitat (ecosystem) types

**Datasets:**

- Datasets required to develop disturbance/intactness maps
    - Canadian human footprint (300m)
    - National linear disturbances (seismic lines and roads)
        - ACTION ITEM: acquire linear disturbances from Lucy Poley
    - Wildfire and forest harvest maps for 1985-2015 (30m) from [Satellite Forest Information for Canada](https://opendata.nfis.org/mapserver/nfis-change_eng.html)
    - Regional disturbance map for SE Yukon and NE BC (future)
        - ACTION ITEM: connect with BEACONs disturbance mapping project
- Habitat types
    - NALC 2015 (30m)
    - High-resolution annual forest land cover maps for Canada’s forested ecosystems (1984-2019)

**Tools:**

- Circuitscape (Omniscape); Appropriate for 1) multiple species, 2) no clear binary nodes, 3) more intact landscapes, and 4) widespread/ranging generalist species
- Linkage Mapper (more suited to identifying specific corridors between IPCAs)

**References:**

- TNC - Resilient and Connected Landscapes (Anderson et al. 2016)

**Tasks:**

- Identify important habitat and ecosystem types
    - ACTION ITEM: which are important in our region?
- Develop resistance grid comprising intactness and land cover
- Map connectivity using Circuitscape. TNC report details this approach and a novel Circuitscape analysis to get ‘flow’ across a large landscape. ‘Flow’ can then be used as an input to other connectivity analyses (e.g. prioritising riparian areas).

### Aquatic ecosystem connectivity

The overall goal is to evaluate aquatic connectivity as a system or its individual components:  i) wetland connectivity, ii) riparian connectivity, iii) lotic connectivity.

**Datasets:**

- Wetlands
    - ACTION ITEM: Ask Kim about wetland products in SE Yukon (DUCs?)
    - 1:50,000 LED map
- Riparian
    - ACTION ITEM: Are there any maps in Yukon of riparian areas. Often mapped as potential riparian habitat based on stream data and DEMs.
- Lotic
    - Stream network

**Tools:**

- Wetlands
    - Circuitscape between wetlands. Could use LED to make a resistance surface.
- Riparian
    - TNC/Krosby 2018 analysis (requires mapped riparian areas) methods to rank riparian areas
- Lotic
    - Dendritic connectivity index

**References:**

- Riparian corridors
    - TNC - Resilient and Connected Landscapes
    - Krosby 2018 - Identifying riparian climate corridors to inform climate adaptation planning

**Tasks:**

- Develop methods for assessing wetland connectivity. This could be a similar analysis to ‘Terrestrial ecosystem connectivity’ above.
- Develop methods for assessing riparian connectivity. General approach for riparian corridors is to map potential riparian areas then rank them based on connectivity flow, intactness, size, temperature gradients, tree cover etc. Creating our own riparian areas map would be possible but probably quite a lot of work.
- Develop methods for assessing lotic connectivity. Dendritic connectivity within reserves or areas of interest (i.e. corridors).

### Focal species habitat connectivity

The overall goal is to evaluate connectivity for i) culturally significant species, ii) species at risk and iii) indicator species e.g.,  surrogates, umbrella, and ecosystem engineers. Developing resistance surfaces for individual species will be a key component. Specific objectives include:

- Evaluate ecological connectivity for selected culturally significant species
- Evaluate ecological connectivity for species at risk
- Evaluate ecological connectivity for indicator species

**Datasets:**

- Datasets to develop species-specific resistance surfaces
- Existing predicted species distribution maps
- Input datasets that can be used to created predicted species distribution maps from existing SDM or RSF models

**Tools:**

- Circuitscape (Omniscape)
- GrapHab

**References:**

**Tasks:**

- Select focal species with LFN and other collaborators and partners
- Identify and acquire species distribution models for selected focal species
    - Peer reviewed literature and published reports
    - Indigenous knowledge
- Develop species-specifi intactness/disturbance maps and quantify resistance values for focal species

### Bio-cultural connectivity

The focus here could be on something like using land use and occupancy maps, or culturally important sites, creating a ‘heat map’ from this and overlaying.. perhaps.. prelim idea. Such maps -have- been created for TH and NND to an extent, but would require data sharing agreements.

From Beazley et al. 2021 on Transboundary Connectivity Conservation: “Bison, caribou, and other such species are biocultural keystones, important to Indigenous food, lifeways, spirituality, and other reciprocal cultural and stewardship responsibilities and land-based systems and practices.”

**Note:** One consideration I’ve been grappling with is *if* FN knowledge is part of a process, how is the process helping continually regenerate/enforce that knowledge system? The science systems we use, in ways, reinforce themselves by their very nature (need to go out and monitor, need expertise that requires training in sciences). Maybe beyond all this but something to keep in mind.

**Datasets:**

- Land Use and Occupancy maps which may include but limited to: trails, sites of cultural importance, sites of harvest
    - Seems some of this knowledge is out there, unsure where.
- Could use ‘cultural species information’ to create mapping products from a ‘traditional ecological knowledge’ perspective, as Jean Polfus and Round River have done with TRT.
- Cultural ‘beliefs’ about the land - been considering how to do this, and think it’s more of a framing problem in ways, for example - there is some animism attributed to the land and animals in some Kaska knowledge, this can be integrated into the way ‘science’ is communicated and what options may or may not be possible through science.
    - YESAB Submissions may have some of this, public documents also.

**Tools:**

- The land use and occupancy maps could be folded into a spatial analysis, some values could be critical, ie. ‘cultural keystone places’.
- Nvivo? - Excel could serve this purpose in ways too.

**References:**

**Tasks:**

- Important habitat and species should arise from community working with, some of this could be gathered from existing documents.
- This could be a ‘thought piece’ development, where biocultural information is informing parts of the process.
- Potential task could be review of publicly available knowledge in an area I am currently considering a ‘Qualitative Content Analysis’ methodology.

## Evaluate projected effects of climate and land use change

### Effects of land use activities on connectivity

The overall goal is to evaluate past, present, and future changes in land use and land cover on ecological connectivity. Features to be connected can be selected from the ones used for the other objectives. The permeability/resistance of the surface is another key component that also has overlap with the previous objectives. Specific objectives include:

- Evaluate the effects of recent changes (~30 years) in land use / land cover on connectivity
- Evaluate the effects of proposed land use activities on connectivity e.g., proposed road or mine
- Evaluate the effect of simulated land cover changes on connectivity

**Datasets:**

- Multi-year land cover dataset (e.g., ESA 1986-2015)
- Disturbance/intactness maps for past and present

**Tools:**

- To be determined (see Tasks)

**References:**

**Tasks:**

- Assess changes in land cover during the past 30 years
    - Use CEC land cover data to quantify changes in natural and anthropogenic land cover classes.
- Evaluate effects of proposed land use activities
    - Identify proposed land use activities of concern e.g., mining and/or roads.
    - Use methods developed above to evaluate impacts of proposed activities on ecological connectivity i.e., CPA/terrestrial/aquative connectivity.
- Develop tool to evaluate proposed or simulated land use change
    - Three possible approaches: i) adapt CONSERV, ii) develop SPADES module, or iii) develop standalone R/Shiny app.

### Effects of climate change on connectivity

The overall goal is to evaluate the potential effects of climate change scenarios on ecological connectivity and to develop methods for incorporating climate-resilient design into BEACONs conservation planning approach. Specific objectives include:

1. Identify and prioritize areas of high landscape integity between PCAs that can serve as corridors or stepping stones (also listed under “Protected and Conserved Area Connectivity”)
2. Identify corridors that follow temperature and precipitation gradients that may assist individuals tracking suitable climates
3. Identify areas that are expected to remain climatically suitable (stable) for individual species over a given planning horizon
4. Identify areas that provide dispersal pathways between stable habitat and locations that will be climatically suitable in the future

**Datasets:**

- Existing North America wide climate analogs, refugia, and velocity datasets from AdaptWest.
- Intactness map (combination of existing maps or new map (see disturbance mapping project)

**Tools:**

- Circuitscape

**References:**

- Parks et al. 2020, Dobrowski et al. 2021

**Tasks:**

- Define planning region and baseline and projected time periods for analyses.
- Evaluate “usefulness” of existing baseline and projected datasets for regional connectivity planning (criteria: resolution, range of variability).
- If desired, develop regional-scale climate change datasets
    - Acquire information on methods for creating regional datasets
    - Evaluate feasibility of creating regional datasets
    - Develop regional-scale datasets
- Create multi-temporal database with common extent, resolution, and projection.
- Obj 1: Identify and prioritize high intactness areas e.g., corridors, stepping stones
    - See detailed methods under “Protected and Conserved Area Connectivity”
- Obj 2: Identify corridors that follow temperature and precipitation gradients
    - Methods to be developed
- Obj 3: Identify areas that are expected to remain climatically suitable
    - Select focal species (see Focal Species Habitat Connectivity)
    - Acquire or develop SDM for selected focal species
    - Can also evaluate ‘general’ suitability using refugia datasets from Adaptwest
    - Develop methods to evaluate connectivity (e.g., Dobrowski et al. 2021)
- Obj 4: Identify areas that provide dispersal pathways
    - Use same focal species and SDMs as above
    - Develop methods to evaluate connectivity (e.g., Dobrowski et al. 2021)
- Develop and implement methods for quantifying the effects of uncertainty in existing and projected datasets.
