# Useful Skips for adding folks to a specific century

## 20th century
### Text Contains

```
Category:(?:20(?:[1-9]\d|0[2-9]) deaths|Living people|British (?:psychiatrists|consciousness researchers and theorists))
```
### Doesn't Contain

```
Category:(19\d\d|18[89]\d) births
```

## Scientists
### Text Contains

```
...
```

### Doesn't Contain

```
Category:(?:[A-Z\da-z\s\-]*\s)?(?:[aA](?:gronomists|natomists|stronomers)|[bB](?:otanists|iologists|ioengineers)|[cC](?:hemists|limatologists|ryptographers)|[eE](?:mbryologists)|[gG](?:eologists)|[hH]ydrologists|[iI]mmunologists|[mM](?:edical researchers|eteorologists|athematicians)|[nN]euroscientists|[oO]ceanographers|[Pp](?:athologists|harmacologists|hysiologists|sychologists|hysicists)|[sS](?:cientists|ociologists))
```

## Physicians
### Text Contains

```
...
```

### Doesn't Contain

```
Category:(?:[A-Z\da-z\s\-]*\s)?(?:[Pp](?:hysicians|sychiatrists)|[mM]edical doctors|[sS]urgeons)
```

## Lawyers
### Text Contains

```
...
```

### Doesn't Contain

```
Category:(?:[A-Z\da-z\s\-]*\s)?(?:[Ll]awyers|[jJ](?:udges|urists|ustices)|[Ss]olicitors|[bB]arristers)
```

## Politicians
### Text Contains

```
...
```

### Doesn't Contain

```
Category:(?:[A-Z\da-z\s\-]*\s)?(?:[Pp](?:oliticians|arty members)|[sS]enators|[mM](?:inisters|ayors)|[cC]ity councill?ors)
```

## People from a specific nationality who aren't already in a disability subcategory
### Text Contains

```
Category:(?:(?:English|Welsh|Scot+ish) (?:people with disabilities|deaf people|amputees|blind people)|Paralympic [\d\w\s]+ for Great Britain\]\]|British blind people)|(?:from|in) British Columbia\]\]
```
### Doesn't Contain

```
Category:(?:[A-Z\da-z\s\-]*\s)?(?:British)(?! (?:Games|University|Revolution|amputees|blind|d(?:isabled sportspeople|e(?:af|scent))|politicians with disabilities)|-language)
```
## Case Laws without a year
### Text Contains
```
in (?:(?:A(?:merican|ustralian?)|British|Canad(?:ian|a)|European Union|Indian?|New Zealand|South African?|United (?:States|Kingdom)) )?case law(?:\]\]|\|)
```
### Doesn't Contain

```
...
```
