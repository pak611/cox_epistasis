
devtools::load_all("C:/Users/patri/Dropbox/Ph.D/Research/Doctoral_Research/Bioinformatics/coxed/cox_epistasis")


num.covariates <- 10
num.inst <- 300
# Lets try user defined beta values (coefficients)
factor <- 10

coefficients <- rep(1,num.covariates)

coefficients[c(3,5)] <- coefficients[c(3,5)] * factor



# specify the interactions matrix as a [1:num.inst, 1:num.covariates] matrix
# Initialize the matrix with zeros
inter.mat <- matrix(0, nrow=num.inst, ncol=num.covariates)

# Set the elements at [1,2] and [2,1] to 1
inter.mat[1,2] <- 5
inter.mat[2,1] <- 5

# Make T bigger and decrease the variance of the X variables
# N = 200: number of observations
# T = 5: maximum time
# xvars = 19: number of covariates
# censor = 0.2: censoring rate (proportion of observations that are censored)
# num.data.frames = 1: number of datasets to simulate
simdata <- coxed::sim.survdata(N=num.inst, T=40, xvars = num.covariates, censor = 0.2, num.data.frames=1, beta=coefficients/2, interactions=TRUE, inter.mat=inter.mat)

# View the first few rows of the simulated data
str(simdata)

# round simsuve to the nearest integer


# output simdata to a csv
write.csv(simdata$data, "C:/Users/patri/Dropbox/Ph.D/Research/Doctoral_Research/Bioinformatics/coxed/cox_epistasis/data")
