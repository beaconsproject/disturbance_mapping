## Mapping methods

Mapping landscape condition can help identify and prioritize intact areas that can be set aside in conservation areas. To assess landscape condition, an approach known as cumulative impact mapping is often used (Ban et al. 2010). This approach uses data on multiple human activities known to impact biodiversity, and combines them to generate a single index measuring human pressure on the landscape, known as the human footprint (Sanderson et al. 2002, Venter et al. 2016). For example, Mu et al. (2021) considered the following human pressures: (1) the extent of built environments, (2) human population density, (3) night-time lights, (4) crop land, (5) pasture, (6) roads, (7) railways, and (8) navigable waterways. Each pressure was placed on a 0–10 scale and then summed together to create an overall human footprint index (Table 1).

Table 1. Scoring details for the human footprint taken from Mu et al. (2021).

<table>
<colgroup>
<col style="width: 21%" />
<col style="width: 9%" />
<col style="width: 68%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Pressure</strong></th>
<th><strong>Score</strong></th>
<th><strong>Details</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Built environment</td>
<td>0,4,10</td>
<td>The pressure score for pixels with urban fractions above 20% was
assigned as 10; otherwise, it was assigned as 4.</td>
</tr>
<tr class="even">
<td>Population density</td>
<td>0-10</td>
<td><p>10, population(P) ≥ 1000</p>
<p>3.333 x log(P + 1), 0 &lt; P &lt;1000</p></td>
</tr>
<tr class="odd">
<td>Night-time lights</td>
<td>0-10</td>
<td>Assigned from 0 to 10 according to intervals determined by ten equal
quantiles</td>
</tr>
<tr class="even">
<td>Croplands</td>
<td>0,4,7</td>
<td>The pressure score for pixels with crop fraction above 20% was
assigned as 7; otherwise, it was assigned as 4.</td>
</tr>
<tr class="odd">
<td>Pasture</td>
<td>0-4</td>
<td>Fraction of pasture in each grid multiplied by 4</td>
</tr>
<tr class="even">
<td>Roads</td>
<td>0-8</td>
<td><p>8, distance(D) ≤ 0.5</p>
<p>3.75 x exp(-1 x (D - 1)) + 0.25, 0.5 &lt; D &lt; 15</p></td>
</tr>
<tr class="odd">
<td>Railways</td>
<td>0,8</td>
<td><p>0, distance(D) &gt; 0.5</p>
<p>8, D ≤ 0.5</p></td>
</tr>
<tr class="even">
<td>Navigable waterways</td>
<td>0-4</td>
<td>DD 0, () 15 4exp (1 ), 15 </td>
</tr>
</tbody>
</table>


### Classifying intact areas

To separate intact and degraded areas, several previous studies and defined degraded areas as those where human footprint scores were greater than four ([Di Marco et al. 2018](https://www.nature.com/articles/s41467-018-07049-5), [Jones et al. 2018](https://www.science.org/doi/10.1126/science.aap9565), [Jones et al. 2022](https://conbio.onlinelibrary.wiley.com/doi/10.1111/csp2.12686), [Venter et al. 2016](https://www.nature.com/articles/ncomms12558)).

Classes:

- Wilderness: Human Footprint \< 1
- Intact areas: Human Footprint \< 4
- Highly modified areas: Human Footprint \>= 4

### References

Ban et al. 2010. Cumulative impact mapping: Advances, relevance and limitations to marine management and conservation, using Canada's Pacific waters as a case study. URL: https://www.sciencedirect.com/science/article/abs/pii/S0308597X10000114

Hirsh-Pearson et al. 2022. Canada Human footprint 2020. URL: https://www.facetsjournal.com/doi/full/10.1139/facets-2021-0063

- <https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP2/EVKAVL>

Mu et al. 2021. Human footprint 2000-2018.

- <https://github.com/HaoweiGis/humanFootprintMapping/>
- <https://figshare.com/articles/figure/An_annual_global_terrestrial_Human_Footprint_dataset_from_2000_to_2018/16571064>

Sanderson et al. 2002. The Human Footprint and the Last of the Wild: The human footprint is a global map of human influence on the land surface, which suggests that human beings are stewards of nature, whether we like it or not. BioScience 52(10):891–904. URL: https://academic.oup.com/bioscience/article/52/10/891/354831

Venter et al. 2016a. Human footprint 1993-2009

Venter et al. 2016b. Human footprint 1993-2009

Williams et al. 2020. Human footprint 2000-2013

- <https://github.com/scabecks/humanfootprint_2000-2013>



