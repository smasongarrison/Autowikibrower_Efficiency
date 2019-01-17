installed.packages()[c("base","ore","stringi"),"Version"]

library(ore)
library(stringi)
library(microbenchmark)
library(methods)
library(ggplot2)
sessionInfo()
cat(grep("^[#\\s]+configure", readLines(file.path(R.home("etc"),"Makeconf")), perl=TRUE, value=TRUE))
# Target document: The Adventures of Sherlock Holmes
text <- readLines("pg1661.txt", encoding="UTF-8")

regexes <- c("Sherlock",
             "^Sherlock",
             "Sherlock$",
             "a[^x]{20}b",
             "Holmes|Watson",
             ".{0,3}(Holmes|Watson)",
             "[a-zA-Z]+ing",
             "^([a-zA-Z]{0,4}ing)[^a-zA-Z]",
             "[a-zA-Z]+ing$",
             "^[a-zA-Z ]{5,}$",
             "^.{16,20}$",
             "([a-f](.[d-m].){0,2}[h-n]){2}",
             "([A-Za-z]olmes|[A-Za-z]atson)[^a-zA-Z]",
             "\"[^\"]{0,30}[?!\\.]\"",
             "Holmes.{10,60}Watson|Watson.{10,60}Holmes")

methods <- c("base (PCRE)", "ore", "ore (precompiled)", "stringi")

.makeResult <- function (benchmark, ...)
{
  benchmark$time <- benchmark$time / 1000
  benchmark$method <- benchmark$expr
  levels(benchmark$method) <- methods
  return (cbind(benchmark, data.frame(...)))
}

# This function runs the benchmark and collates the results. With vector=TRUE,
# the lines are passed as a vector, otherwise they are concatenated into a
# single long string.
regexTest <- function (vector = FALSE)
{
  results <- NULL
  
  if (!vector)
    text <- paste(text, collapse="\n")
  
  for (regex in regexes)
  {
    if (vector)
    {
      # No-op cases
      stringiOpts <- NULL
      prefixedRegex <- regex
    }
    else
    {
      # Set the multiline options for PCRE and ICU4C, needed to ensure
      # that ^ and $ are interpreted correctly. Oniguruma does this by
      # default, so no special option is needed.
      stringiOpts <- stri_opts_regex(multiline=TRUE)
      prefixedRegex <- paste("(?m)", regex, sep="")
    }
    
    # Compile the regex for use with ore.search
    compiledRegex <- ore(regex, encoding="UTF-8")
    
    # Run the benchmark for ten iterations each, in a randomised order
    benchmark <- microbenchmark(gregexpr(prefixedRegex, text, perl=TRUE),
                                ore.search(regex, text, all=TRUE),
                                ore.search(compiledRegex, text, all=TRUE),
                                stri_locate_all_regex(text, regex, opts_regex=stringiOpts),
                                times=10L)
    
    # Append the results to the main data frame
    results <- rbind(results, .makeResult(benchmark,regex=regex))
  }
  
  results$regex <- factor(results$regex, levels=regexes)
  return(results)
}

# This function plots the benchmark results. If log=TRUE then the times are
# shown on a logarithmic axis.
plot <- function (results, log = TRUE)
{
  # Build the plot
  plot <- ggplot(results, aes(x=method,y=time,fill=method)) +
    stat_summary(fun.y="median", geom="bar") +
    geom_point(colour=rgb(0,0,0,0.5)) +
    coord_flip() +
    xlab("") +
    ylab(expression(paste("time, ",mu,"s")))
  
  if ("regex" %in% colnames(results))
    plot <- plot + facet_wrap(~regex) + theme(strip.text=element_text(size=rel(0.6)), legend.position=c(0.9,0.12))
  else
    plot <- plot + facet_wrap(~task) + theme(legend.position=c(0.85,0.3))
  
  # Use a log scale if requested
  if (log)
    return(plot + scale_y_log10())
  else
    return(plot)
}

results <- regexTest(vector=FALSE)
plot(results)

taskTest <- function (regex, vector = FALSE)
{
  results <- NULL
  
  if (!vector)
    text <- paste(text, collapse="\n")
  
  if (vector)
  {
    # No-op cases
    stringiOpts <- NULL
    prefixedRegex <- regex
  }
  else
  {
    # Set the multiline options for PCRE and ICU4C, needed to ensure
    # that ^ and $ are interpreted correctly. Oniguruma does this by
    # default, so no special option is needed.
    stringiOpts <- stri_opts_regex(multiline=TRUE)
    prefixedRegex <- paste("(?m)", regex, sep="")
  }
  
  # Compile the regex for use with ore.search
  compiledRegex <- ore(regex, encoding="UTF-8")
  
  # Search only
  benchmark <- microbenchmark(gregexpr(prefixedRegex, text, perl=TRUE),
                              ore.search(regex, text, all=TRUE),
                              ore.search(compiledRegex, text, all=TRUE),
                              stri_locate_all_regex(text, regex, opts_regex=stringiOpts),
                              times=10L)
  results <- rbind(results, .makeResult(benchmark,task="search only"))
  
  # Extracting matches
  benchmark <- microbenchmark(regmatches(text, gregexpr(prefixedRegex, text, perl=TRUE)),
                              ore.search(regex, text, all=TRUE),
                              ore.search(compiledRegex, text, all=TRUE),
                              stri_match_all_regex(text, regex, opts_regex=stringiOpts),
                              times=10L)
  results <- rbind(results, .makeResult(benchmark,task="extracting matches"))
  
  # Splitting by regex
  benchmark <- microbenchmark(strsplit(text, prefixedRegex, perl=TRUE),
                              ore.split(regex, text),
                              ore.split(compiledRegex, text),
                              stri_split_regex(text, regex, opts_regex=stringiOpts),
                              times=10L)
  results <- rbind(results, .makeResult(benchmark,task="splitting by regex"))
  
  # Simple substitution
  benchmark <- microbenchmark(gsub(prefixedRegex, "*...ing*", text, perl=TRUE),
                              ore.subst(regex, "*...ing*", text, all=TRUE),
                              ore.subst(compiledRegex, "*...ing*", text, all=TRUE),
                              stri_replace_all_regex(text, regex, "*...ing*", opts_regex=stringiOpts),
                              times=10L)
  results <- rbind(results, .makeResult(benchmark,task="simple substitution"))
  
  # Back-referenced substitution
  benchmark <- microbenchmark(gsub(prefixedRegex, "*\\1*", text, perl=TRUE),
                              ore.subst(regex, "*\\1*", text, all=TRUE),
                              ore.subst(compiledRegex, "*\\1*", text, all=TRUE),
                              stri_replace_all_regex(text, regex, "*$1*", opts_regex=stringiOpts),
                              times=10L)
  results <- rbind(results, .makeResult(benchmark,task="back-referenced substitution"))
  
  results$task <- factor(results$task)
  return(results)
}