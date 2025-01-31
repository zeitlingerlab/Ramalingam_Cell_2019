<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template name="meme.css">
    <![CDATA[
    /* START INCLUDED FILE "meme.css" */
/* The following is the content of meme.css */
body { background-color:white; font-size: 12px; font-family: Verdana, Arial, Helvetica, sans-serif;}

div.help {
  display: inline-block;
  margin: 0px;
  padding: 0px;
  width: 12px;
  height: 13px;
  cursor: pointer;
  background-image: url(data:image/gif;base64,R0lGODlhDAANAIABANR0AP///yH5BAEAAAEALAAAAAAMAA0AAAIdhI8Xy22MIFgv1DttrrJ7mlGNNo4c+aFg6SQuUAAAOw==);
}

div.help:hover {
  background-image: url(data:image/gif;base64,R0lGODlhDAANAKEAANR0AP///9R0ANR0ACH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEAAAIALAAAAAAMAA0AAAIdDGynCe3PgoxONntvwqz2/z2K2ImjR0KhmSIZUgAAOw==);
}

p.spaced { line-height: 1.8em;}

span.citation { font-family: "Book Antiqua", "Palatino Linotype", serif; color: #004a4d;}

p.pad { padding-left: 30px; padding-top: 5px; padding-bottom: 10px;}

td.jump { font-size: 13px; color: #ffffff; background-color: #00666a;
  font-family: Georgia, "Times New Roman", Times, serif;}

a.jump { margin: 15px 0 0; font-style: normal; font-variant: small-caps;
  font-weight: bolder; font-family: Georgia, "Times New Roman", Times, serif;}

h2.mainh {font-size: 1.5em; font-style: normal; margin: 15px 0 0;
  font-variant: small-caps; font-family: Georgia, "Times New Roman", Times, serif;}

h2.line {border-bottom: 1px solid #CCCCCC; font-size: 1.5em; font-style: normal;
  margin: 15px 0 0; padding-bottom: 3px; font-variant: small-caps;
  font-family: Georgia, "Times New Roman", Times, serif;}

h4 {border-bottom: 1px solid #CCCCCC; font-size: 1.2em; font-style: normal;
  margin: 10px 0 0; padding-bottom: 3px; font-family: Georgia, "Times New Roman", Times, serif;}

h5 {margin: 0px}

a.help { font-size: 9px; font-style: normal; text-transform: uppercase;
  font-family: Georgia, "Times New Roman", Times, serif;}

div.pad { padding-left: 30px; padding-top: 5px; padding-bottom: 10px;}

div.pad1 { margin: 10px 5px;}

div.pad2 { margin: 25px 5px 5px;}
h2.pad2 { padding: 25px 5px 5px;}

div.pad3 { padding: 5px 0px 10px 30px;}

div.box { border: 2px solid #CCCCCC; padding:10px; overflow: hidden;}

div.bar { border-left: 7px solid #00666a; padding:5px; margin-top:25px; }

div.subsection {margin:25px 0px;}

img {border:0px none;}

th.majorth {text-align:left;}
th.minorth {font-weight:normal; text-align:left; width:8em; padding: 3px 0px;}
th.actionth {font-weight:normal; text-align:left;}

.explain h5 {font-size:1em; margin-left: 1em;}

div.doc {margin-left: 2em; margin-bottom: 3em;}

th.trainingset {
  border-bottom: thin dashed black; 
  font-weight:normal; 
  padding:0px 10px;
}
div.pop_content {
  position:absolute;
  z-index:50;
  width:300px;
  padding: 5px;
  background: #E4ECEC;
  font-size: 12px;
  font-family: Arial;
  border-style: double;
  border-width: 3px;
  border-color: #AA2244;
  display:none;
}
div.pop_content_wide {
  position:absolute;
  z-index:1;
  width:700px;
  padding: 5px;
  background: #E4ECEC;
  font-size: 12px;
  font-family: Arial;
  border-style: double;
  border-width: 3px;
  border-color: #AA2244;
  display:none;
}

div.pop_content > *:first-child {
  margin-top: 0px;
}

div.pop_content h1, div.pop_content h2, div.pop_content h3, div.pop_content h4, 
div.pop_content h5, div.pop_content h6, div.pop_content p {
  margin: 0px;
}

div.pop_content p + h1, div.pop_content p + h2, div.pop_content p + h3, 
div.pop_content p + h4, div.pop_content p + h5, div.pop_content p + h6 {
  margin-top: 5px;
}

div.pop_content p + p {
  margin-top: 5px;
}

div.pop_content > *:last-child {
  margin-bottom: 0px;
}

div.pop_content div.pop_close {
  /* old definition */
  float:right;
  bottom: 0;
}

div.pop_content span.pop_close, div.pop_content span.pop_back {
  display: inline-block;
  border: 2px outset #661429;
  background-color: #CCC;
  padding-left: 1px;
  padding-right: 1px;
  padding-top: 0px;
  padding-bottom: 0px;
  cursor: pointer;
  color: #AA2244; /*#661429;*/
  font-weight: bold;
}

div.pop_content span.pop_close:active, div.pop_content span.pop_back:active {
  border-style: inset;
}

div.pop_content span.pop_close {
  float:right;
  /*border: 2px outset #AA002B;*/
  /*color: #AA2244;*/
}

div.pop_content:not(.nested) .nested_only {
  display: none;
}

div.pop_back_sec {
  margin-bottom: 5px;
}

div.pop_close_sec {
  margin-top: 5px;
}

table.hide_advanced tr.advanced {
  display: none;
}
span.show_more {
  display: none;
}
table.hide_advanced span.show_more {
  display: inline;
}
table.hide_advanced span.show_less {
  display: none;
}


/*****************************************************************************
 * Program logo styling
 ****************************************************************************/
div.prog_logo {
  border-bottom: 0.25em solid #0f5f60;
  height: 4.5em;
  width: 24em;
  display:inline-block;
}
div.prog_logo img {
  float:left;
  width: 4em;
  border-style: none;
  margin-right: 0.2em;
}
div.prog_logo h1, div.prog_logo h1:hover, div.prog_logo h1:active, div.prog_logo h1:visited {
  margin:0;
  padding:0;
  font-family: Arial, Helvetica,  sans-serif;
  font-size: 3.2em;
  line-height: 1em;
  vertical-align: top;
  display: block;
  color: #026666;
  letter-spacing: -0.06em;
  text-shadow: 0.04em 0.06em 0.05em #666;
}
div.prog_logo h2, div.prog_logo h2:hover, div.prog_logo h2:active, div.prog_logo h2:visited {
  display: block;
  margin:0;
  padding:0;
  font-family: Helvetica, sans-serif;
  font-size: 0.9em;
  line-height: 1em;
  letter-spacing: -0.06em;
  color: black;
}
div.prog_logo h3, div.prog_logo h3:hover, div.prog_logo h3:active, div.prog_logo h3:visited {
  display: block;
  margin:0;
  padding:0;
  font-family: Helvetica, sans-serif;
  font-size: 0.9em;
  line-height: 1.5em;
  letter-spacing: -0.06em;
  color: black;
}

div.big.prog_logo {
  font-size: 18px;
}

/* These are for centered columns in tables */
td.ctr {
  text-align: center;
}

/* These are for the navigation bars at the top of outputs. */
table.navigation {
  margin-top: 0px;
  border-collapse:collapse;
}
table.navigation * td
{
  padding-left: 0px;
  padding-right: 10px;
  padding-top: 0px;
  padding-bottom: 0px;
}
    /* END INCLUDED FILE "meme.css" */
    ]]>
  </xsl:template>
</xsl:stylesheet>

