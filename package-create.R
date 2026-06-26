#This file is used to build the package and items here are not
#imported into the package to users.

# ---------- Initial Setup ----------
## ONLY RUN ON FIRST SETUP
#install.packages("devtools")
#install.packages("roxygen2")
#devtools::create("camRa")
#usethis::use_pkgdown()
#usethis::use_readme_rmd()
#usethis::use_gpl_license()

# Index Files for Latex
#MANUAL: install MiKTeX, https://miktex.org/download
#Sys.setenv(
# PATH = paste(Sys.getenv("PATH"), "~/MiKTeX/miktex/bin/x64", # replace w/ your path to MiKTex
# sep = .Platform$path.sep)
#)

# ---------- Try Install/Load Package to R Env. ----------
devtools::install()
library(camRa)
remove.packages(camRa)

# ---------- Create Objects ----------
#Create Public Data Object
usethis::use_data(DATASET_OBJ_HERE)

#Create Private Data Object
usethis::use_data(DATASET_OBJ_HERE, internal = TRUE, overwrite = TRUE)

#Get System Data (Example)
#system.file('extdata', 'ena24subset_MegaDet_recognition.json', package = "camRa")

# ---------- Make Vignette ----------
#usethis::use_vignette("MY-VINGETTE-NAME")

# ---------- Update Documentation ----------
#Run this entire section when making the package
#Documentation Files
devtools::document()

#Documentation PDF
##Rename to prevent multiple copies w/ version change
devtools::build_manual(path = getwd())
file.rename(
  paste0('camRa_', packageDescription(pkg = 'camRa')$Version, '.pdf'),
  'camRa_documentation.pdf'
)

#README
devtools::build_readme()

#Vignettes
devtools::build_vignettes()

#Build Web
##Locally
pkgdown::build_site()

##For GitHub
pkgdown::build_site_github_pages()

#Make robots.txt
writeLines(con = 'docs/robots.txt', text = "# Block OpenAI's crawlers
User-agent: GPTBot
Disallow: /

User-agent: ChatGPT-User
Disallow: /

# Block Anthropic's crawler
User-agent: ClaudeBot
Disallow: /

# Block Google's AI training crawler
User-agent: Google-Extended
Disallow: /

# Block Perplexity
User-agent: PerplexityBot
Disallow: /

# Generic block for all other bots (Note: will also block standard search crawlers if not careful)
# User-agent: *
# Disallow: /")

#Make ai.txt
writeLines(con = 'docs/ai.txt', text = "User-Agent: *
No-Training: *
No-Inference: *")

#Delete llms.txt
file.remove('docs/llms.txt')
