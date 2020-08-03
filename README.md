Some simple common utils for our projects.


## SLD

Simple SLD styling is supported.

Features:

* parsing of point/line/polygon/text symbolizers
* writing of point/line/polygon/text symbolizers
* add or remove symbolizers to/from rule
* geotools and QGIS SLDs are equally supported at the current time

### Attributes parsed and their default value

Point:

* markerName = "Circle";
* markerSize = 5;
* fillColorHex = "#000000";
* fillOpacity = 1.0;
* strokeColorHex = "#000000";
* strokeWidth = 1.0;
* strokeOpacity = 1.0;

Line:

* strokeColorHex = "#000000";
* strokeWidth = 1.0;
* strokeOpacity = 1.0;

Polygon:

* fillColorHex = "#000000";
* fillOpacity = 1.0;
* strokeColorHex = "#000000";
* strokeWidth = 1.0;
* strokeOpacity = 1.0;

Text:

* labelName = "";
* textColor = "#000000";
* size = 12;
* haloSize = 1.0;
* haloColor = "#FFFFFF";

### Filters 

At the moment the only Rule filter supported is the one based on unique values that are created using **PropertyIsEqualTo**, i.e. something like

```
<ogc:Filter>
    <ogc:PropertyIsEqualTo>
        <ogc:PropertyName>region</ogc:PropertyName>
        <ogc:Literal>Abruzzo</ogc:Literal>
    </ogc:PropertyIsEqualTo>
</ogc:Filter>
```