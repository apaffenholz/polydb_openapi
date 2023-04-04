#!/bin/bash

outfile=$1
if [ -z "$1" ]
  then
    outfile="polydb-rest.html"
fi

mkdir -p out
tmpdir=$(mktemp -d)
tmpfile="$tmpdir/polydb-bundled.json"
tmpfile2="$tmpdir/polydb-enriched.json"

npx @redocly/cli bundle --output $tmpfile --lint=true polydb_openapi/polydb-master.yaml --skip-rule='security-defined'

TARGETS="shell_httpie,shell_curl,shell_wget,php_curl,php_http1,php_http2,python_python3,python_requests"
./oas3-api-snippet-enricher/bin/snippet-enricher-cli --targets=${TARGETS} --input=$tmpfile > $tmpfile2

npx @redocly/cli build-docs \
  --theme.openapi.theme.colors.primary.main "rgb(151,86,42)" \
  --theme.openapi.theme.sidebar.backgroundColor white  \
  --theme.openapi.theme.typography.fontFamily "Raleway,sans-serif" \
  --theme.openapi.theme.typography.headings.fontFamily "Raleway,sans-serif" \
  --theme.openapi.theme.sidebar.textColor "rgb(151,86,42)" \
  --theme.openapi.theme.sidebar.activeTextColor "rgb(234,168,40)" \
  --theme.openapi.theme.sidebar.activeBgColor "#ddd" \
  --theme.openapi.theme.sidebar.rightLineColor "red" \
  --theme.openapi.theme.logo.gutter "10px" \
  --output=out/$outfile \
  -t redoc/custom.hbs \
  $tmpfile2

sed -i "" "s/openapi.json/polydb-openapi.json/" out/$outfile

rm -r $tmpdir
