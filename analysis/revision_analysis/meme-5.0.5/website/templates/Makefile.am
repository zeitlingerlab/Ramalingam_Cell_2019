##
## Process this file with automake to produce Makefile.in
##

AUTOMAKE_OPTIONS = no-dependencies

memelibexecdir = ${libexecdir}/${PACKAGE_NAME}-${PACKAGE_VERSION}

SOURCE_TMPL_FILES = \
centrimo.tmpl.in \
component_footer.tmpl.in \
dreme.tmpl.in \
glam2.tmpl.in \
meme-chip.tmpl.in \
meme.tmpl.in \
spamo.tmpl.in

NORMAL_TMPL_FILES = \
ame.tmpl \
ame_verify.tmpl \
centrimo_verify.tmpl \
cismapper.tmpl \
cismapper_verify.tmpl \
component_adv_btn.tmpl \
component_bfile.tmpl \
component_cismapper.tmpl \
component_glam2motifs.tmpl \
component_gomo.tmpl \
component_header.tmpl \
component_job_details.tmpl \
component_loci.tmpl \
component_glam2motifs.tmpl \
component_motifs.tmpl \
component_sequences.tmpl \
component_submit_reset.tmpl \
dreme_verify.tmpl \
email.tmpl \
fimo.tmpl \
fimo_verify.tmpl \
glam2_verify.tmpl \
glam2scan.tmpl \
glam2scan_verify.tmpl \
gomo.tmpl \
gomo_verify.tmpl \
mast.tmpl \
mast_verify.tmpl \
mcast.tmpl \
mcast_verify.tmpl \
meme-chip_verify.tmpl \
meme_verify.tmpl \
momo.tmpl \
momo_verify.tmpl \
request_redirect.tmpl \
show_gomo_dbs.tmpl \
show_motif_dbs.tmpl \
show_sequence_dbs.tmpl \
spamo_verify.tmpl \
status.tmpl \
tomtom.tmpl \
tomtom_verify.tmpl \
verify.tmpl \
whine.tmpl

BUILT_TMPL_FILES = \
centrimo.tmpl \
component_footer.tmpl \
dreme.tmpl \
glam2.tmpl \
meme-chip.tmpl \
meme.tmpl \
spamo.tmpl

SED_URLS = -e 's%\@SOURCE_URL\@%$(SOURCE_URL)%g' -e 's%\@SITE_URL\@%$(URL)%g' -e 's%\@DEV_CONTACT\@%$(DEV_CONTACT)%g'

%.tmpl : %.tmpl.in
	$(SED) $(SED_URLS) $< > $@

if WEBSERVICE
noinst_SCRIPTS = $(BUILT_TMPL_FILES) $(NORMAL_TMPL_FILES)
endif

CLEANFILES = $(BUILT_TMPL_FILES)

EXTRA_DIST = $(SOURCE_TMPL_FILES) $(NORMAL_TMPL_FILES)
