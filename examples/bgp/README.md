## get data

```
wget http://thyme.apnic.net/current/data-used-autnums
wget http://data.ris.ripe.net/rrc03/latest-bview.gz
```

## create csv list
```
  bgpdump latest-bview.gz | ruby bgpdump_to_asn.rb data-used-autnums
```
