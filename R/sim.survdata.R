#' Simulating duration data for the Cox proportional hazards model
#'
#' \code{sim.survdata()} randomly generates data frames containing a user-specified number
#' of observations, time points, and covariates.  It generates durations, a variable indicating
#' whether each observation is right-censored, and "true" marginal effects.
#' It can accept user-specified coefficients, covariates, and baseline hazard functions, and it can
#' output data with time-varying covariates or using time-varying coefficients.
#'
#' @param N Number of observations in each generated data frame. Ignored if \code{X} is not \code{NULL}
#' @param T The latest time point during which an observation may fail. Failures can occur
#' as early as 1 and as late as T
#' @param type If "none" (the default) data are generated with no time-varying covariates or coefficients.
#' If "tvc", data are generated with time-varying covariates, and if "tvbeta" data are generated with time-varying
#' coefficients (see details)
#' @param hazard.fun A user-specified R function with one argument, representing time, that outputs the baseline hazard function.
#' If \code{NULL}, a baseline hazard function is generated using the flexible-hazard method as described in Harden and
#' Kropko (2018) (see details)
#' @param num.data.frames The number of data frames to be generated
#' @param fixed.hazard If \code{TRUE}, the same hazard function is used to generate each data frame. If \code{FALSE} (the default),
#' different drawn hazard functions are used to generate each data frame.  Ignored if \code{hazard.fun} is not \code{NULL} or if
#' \code{num.data.frames} is 1
#' @param knots The number of points to draw while using the flexible-hazard method to generate hazard functions (default is 8).
#' Ignored if \code{hazard.fun} is not \code{NULL}
#' @param spline If \code{TRUE} (the default), a spline is employed to smooth the generated cumulative baseline hazard, and if \code{FALSE}
#' the cumulative baseline hazard is specified as a step function with steps at the knots. Ignored if \code{hazard.fun} is not \code{NULL}
#' @param X A user-specified data frame containing the covariates that condition duration. If \code{NULL}, covariates are generated from
#' normal distributions with means given by the \code{mu} argument and standard deviations given by the \code{sd} argument
#' @param beta Either a user-specified vector containing the coefficients for the linear part of the duration model, or
#' a user specified matrix with rows equal to \code{T} for pre-specified time-varying coefficients.
#' If \code{NULL}, coefficients are generated from normal distributions with means of 0 and standard deviations of 0.1
#' @param xvars The number of covariates to generate. Ignored if \code{X} is not \code{NULL}
#' @param mu If scalar, all covariates are generated to have means equal to this scalar. If a vector, it specifies the mean of each covariate separately,
#' and it must be equal in length to \code{xvars}. Ignored if \code{X} is not \code{NULL}
#' @param sd If scalar, all covariates are generated to have standard deviations equal to this scalar. If a vector, it specifies the standard deviation
#' of each covariate separately, and it must be equal in length to \code{xvars}. Ignored if \code{X} is not \code{NULL}
#' @param covariate Specification of the column number of the covariate in the \code{X} matrix for which to generate a simulated marginal effect (default is 1).
#' The marginal effect is the difference in expected duration when the covariate is fixed at a high value and the expected duration when the covariate is fixed
#' at a low value
#' @param low The low value of the covariate for which to calculate a marginal effect
#' @param high The high value of the covariate for which to calculate a marginal effect
#' @param compare The statistic to employ when examining the two new vectors of expected durations (see details).  The default is \code{median}
#' @param censor The proportion of observations to designate as being right-censored
#' @param censor.cond Whether to make right-censoring conditional on the covariates (default is \code{FALSE}, but see details)
#' @details The \code{\link[coxed]{sim.survdata}} function generates simulated duration data. It can accept a user-supplied
#' hazard function, or else it uses the flexible-hazard method described in Harden and Kropko (2018) to generate
#' a hazard that does not necessarily conform to any parametric hazard function. It can generate data with time-varying
#' covariates or coefficients. For time-varying covariates \code{type="tvc"} it employs the permutational algorithm by Sylvestre and Abrahamowicz (2008).
#' For time-varying coefficients with \code{type="tvbeta"}, the user pre-specify either a matrix of time-dependent coefficients with the \code{beta} argument, a vector
#' of coefficients with the \code{beta} argument, or may choose to have coefficients drawn from random normal draws by leaving \code{beta} as \code{NULL}.
#' If the user specifies a matrix, the dimensions of the matrix must be \code{T} by \code{xvars}: the number of time points
#' by the number of X variables. If the user specifies a vector, or if the \code{beta} argument is \code{NULL}, the first beta coefficient
#' is multiplied by the natural log of the failure time under consideration.
#'
#' If \code{fixed.hazard=TRUE}, one baseline hazard is generated and the same function is used to generate all of the simulated
#' datasets. If \code{fixed.hazard=FALSE} (the default), a new hazard function is generated with each simulation iteration.
#'
#' The flexible-hazard method employed when \code{hazard.fun} is \code{NULL} generates a unique baseline hazard by fitting a curve to
#' randomly-drawn points. This produces a wide variety
#' of shapes for the baseline hazard, including those that are unimodal, multimodal, monotonically increasing or decreasing, and many other
#' shapes. The method then generates a density function based on each baseline hazard and draws durations from it in a way that circumvents
#' the need to calculate the inverse cumulative baseline hazard. Because the shape of the baseline hazard can vary considerably, this approach
#' matches the Cox model’s inherent flexibility and better corresponds to the assumed data generating process (DGP) of the Cox model. Moreover,
#' repeating this process over many iterations in a simulation produces simulated samples of data that better reflect the considerable
#' heterogeneity in data used by applied researchers. This increases the generalizability of the simulation results. See Harden and Kropko (2018)
#' for more detail.
#'
#' When generating a marginal effect, first the user specifies a covariate by typing its column number in the \code{X} matrix into the \code{covariate}
#' argument, then specifies the high and low values at which to fix this covariate.  The function calculates the differences in expected duration for each
#' observation when fixing the covariate to the high and low values.  If \code{compare} is \code{median}, the function reports the median of these differences,
#' and if \code{compare} is \code{mean}, the function reports the median of these differences, but any function may be employed that takes a vector as input and
#' outputs a scalar.
#'
#' If \code{censor.cond} is \code{FALSE} then a proportion of the observations specified by \code{censor} is randomly and uniformly selected to be right-censored.
#' If \code{censor.cond} is \code{TRUE} then censoring depends on the covariates as follows: new coefficients are drawn from normal distributions with mean 0 and
#' standard deviation of 0.1, and these new coefficients are used to create a new linear predictor using the \code{X} matrix.  The observations with the largest
#' (100 x \code{censor}) percent of the linear predictors are designated as right-censored.
#' @return Returns an object of class "\code{simSurvdata}" which is a list of length \code{num.data.frames} for each iteration of data simulation.
#' Each element of this list is itself a list with the following components:
#' \tabular{ll}{
#' \code{data} \tab The simulated data frame, including the simulated durations, the censoring variable, and covariates\cr
#' \code{xdata} \tab The simulated data frame, containing only covariates \cr
#' \code{baseline} \tab A data frame containing every potential failure time and the baseline failure PDF,
#' baseline failure CDF, baseline survivor function, and baseline hazard function at each time point. \cr
#' \code{xb} \tab The linear predictor for each observation \cr
#' \code{exp.xb} \tab The exponentiated linear predictor for each observation \cr
#' \code{betas} \tab The coefficients, varying over time if \code{type} is "tvbeta" \cr
#' \code{ind.survive} \tab An (\code{N} x \code{T}) matrix containing the individual survivor function at
#' time t for the individual represented by row n   \cr
#' \code{marg.effect} \tab The simulated marginal change in expected duration comparing the high and low values of
#' the variable specified with \code{covariate} \cr
#' \code{marg.effect.data} \tab The \code{X} matrix and vector of durations for the low and high conditions \cr
#' }
#' @references Harden, J. J. and Kropko, J. (2018). Simulating Duration Data for the Cox Model.
#' \emph{Political Science Research and Methods} \url{https://doi.org/10.1017/psrm.2018.19}
#'
#' Sylvestre M.-P., Abrahamowicz M. (2008) Comparison of algorithms to generate event times conditional on time-dependent covariates. \emph{Statistics in Medicine} \strong{27(14)}:2618–34.
#' @author Jonathan Kropko <jkropko@@virginia.edu> and Jeffrey J. Harden <jharden2@@nd.edu>
#' @export
#' @examples
#' simdata <- sim.survdata(N=1000, T=100, num.data.frames=2)
#' require(survival)
#' data <- simdata[[1]]$data
#' model <- coxph(Surv(y, failed) ~ X1 + X2 + X3, data=data)
#' model$coefficients ## model-estimated coefficients
#' simdata[[1]]$betas ## "true" coefficients
#'
#' ## User-specified baseline hazard
#' my.hazard <- function(t){ #lognormal with mean of 50, sd of 10
#' dnorm((log(t) - log(50))/log(10)) /
#'      (log(10)*t*(1 - pnorm((log(t) - log(50))/log(10))))
#' }
#' simdata <- sim.survdata(N=1000, T=100, hazard.fun = my.hazard)
#'
#' ## A simulated data set with time-varying covariates
#' \dontrun{simdata <- sim.survdata(N=1000, T=100, type="tvc", xvars=5, num.data.frames=1)
#' summary(simdata$data)
#' model <- coxph(Surv(start, end, failed) ~ X1 + X2 + X3 + X4 + X5, data=simdata$data)
#' model$coefficients ## model-estimated coefficients
#' simdata$betas ## "true" coefficients
#' }
#'
#' ## A simulated data set with time-varying coefficients
#' simdata <- sim.survdata(N=1000, T=100, type="tvbeta", num.data.frames = 1)
#' simdata$betas
sim.survdata <- function(N=1000, T=100, type="none", hazard.fun = NULL, num.data.frames = 1,
                         fixed.hazard = FALSE, knots = 8, spline = TRUE,
                         X=NULL, beta=NULL, xvars=3, mu=0, sd=.5,
                         covariate=1, low=0, high=1, compare=median,
                         censor = .1, censor.cond = FALSE, interactions=FALSE, inter.mat=NULL){

     if(!is.null(X)){
          N <- nrow(X)
          xvars <- ncol(X)
     }
     ifelse(is.null(hazard.fun),
            baseline <- baseline.build(T=T, knots=knots, spline=spline),
            baseline <- user.baseline(hazard.fun, T))

     result <- lapply(1:num.data.frames, FUN=function(i){



          if(!fixed.hazard & is.null(hazard.fun)) baseline <- baseline.build(T=T, knots=knots, spline=spline)

          xb <- generate.lm(baseline, X=X, beta=beta, N=N, xvars=xvars, mu=mu, sd=sd, censor=censor, type=type, interactions=interactions, inter.mat=inter.mat)
          data <- xb$data
          if(xb$tvc) xdata <- dplyr::select(data, -id, -failed, -start, -end)
          if(!xb$tvc) xdata <- dplyr::select(data, -y)
          me <- make.margeffect(baseline, xb, covariate, low, high, compare=compare)
          if(type=="none" | type=="tvbeta") ifelse(censor.cond,
                                  data$failed <- !censor.x(xdata, censor=censor),
                                  data$failed <- !(runif(N) < censor))
          if(!is.null(hazard.fun)){
               data$failed[data$y==T] <- TRUE
               r <- sum(data$y==T)
               if(r > .05*N) warning(paste(r, c("additional observations right-censored because the user-supplied hazard function
                                  is nonzero at the latest timepoint. To avoid these extra censored observations, increase T")))
          }
          if(!is.null(beta)){
               exp.low <- baseline$failure.CDF[1]*N
               exp.hi <- baseline$survivor[T-1]*N
               obs.low <- sum(data$y==1)
               obs.hi <- sum(data$y==T)
               p.low <- 1 - pbinom(obs.low, size=N, p=baseline$failure.CDF[1])
               p.high <- 1 - pbinom(obs.hi, size=N, p=baseline$survivor[T-1])
               if(p.low < .025 | p.high < .025){
                    warning(paste(c(obs.hi + obs.low, "observations have drawn durations
                                    at the minimum or maximum possible value. The linear predictor may be
                                    too large to produce a useable survivor function, and generating coefficients
                                    and other quantities of interest are unlikely to be returned.
                                    Consider making user-supplied coefficients
                                    smaller, making T bigger, or decreasing the variance of the X variables."),
                                  collapse = " "))
               }
          }
          return(list(data = data,
                      xdata = xdata,
                      baseline=baseline,
                      xb = xb$XB,
                      exp.xb = xb$exp.XB,
                      betas = xb$beta,
                      ind.survive = xb$survmat,
                      marg.effect = me$marg.effect,
                      marg.effect.data = list(low = me$data.low,
                                              high = me$data.high)))
     })
     if(num.data.frames == 1){
          result <- result[[1]]
          class(result) <- "simSurvdata"
     } else{
          class(result) <- c("simSurvdata", "simSurvdataList")
     }
     return(result)
}
