## Extract filename from metadata (need addMetadata directive in input)
```
set $!FileName = re_extract($!metadata!filename, "([^/]*\$)", 0, 0, "failedToFetchFileName");
```
