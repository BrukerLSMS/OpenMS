## add default CRAN mirror in case the user's config does not have one
options(repos = list(CRAN="http://cran.rstudio.com/"))

if (!require(ggplot2)) install.packages("ggplot2")
library("ggplot2")
if (!require(reshape2)) install.packages("reshape2")
library("reshape2")

file.table.in = commandArgs(TRUE)[1] ## file.table.in = "models.csv"
file.plot.out = commandArgs(TRUE)[2] ## file.plot.out = "output.png"

cat(paste0("Reading file '", file.table.in, "' to plot model parameters ..."))

d = read.csv(file.table.in, check.names = FALSE, comment.char = "#", strip.white = TRUE)
model_count = sum(d$source == "local")

dm = melt(d, id.vars = c("RT", "source"))
head(dm)

## for linear models: remove 'power' graph (it's all 0)
if (all(dm$value[grep("power", dm$variable)] == 0, na.rm=TRUE))
{
  dm = dm[grep("power", dm$variable, invert=TRUE), ]
}

#options(device = "pdf")
#dev.new(filename = file.plot.out, file = file.plot.out)
png(filename = file.plot.out, width=15, height=10, units="cm", res=300)
if (model_count == 0)
{
  plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
  text(0.5,0.5,"Model fitting failed!\nCheck your tool parameters and/or data!")
} else {
  pl = ggplot(dm) + 
        geom_point(aes(x=RT, y=value, col=source)) +
        ggtitle(paste("Model coefficients over time\n", model_count, "model(s)", collapse="")) +
        xlab("RT [sec]") +
        ylab("model coefficient") +
        facet_grid(  variable ~ ., scales="free_y")
  print(pl)
}

dev.off()


