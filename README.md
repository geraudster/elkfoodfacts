
# Helpers

Retrieve fields to be split:

```
head -1 ../data/sample-fr.openfoodfacts.org.products.csv  | tr '\t' '\n' | grep -E 's_fr$|_tags$' | xargs printf 'split => { "%s" => "," }\n'
```
