% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/q_gamma_f.R
\name{q_gamma_f}
\alias{q_gamma_f}
\title{M-Step Expected Log-Likelihood with respect to Gamma}
\usage{
q_gamma_f(gamma_v, Z, obs_Y_matrix, w_mat, sample_size, n_cat)
}
\arguments{
\item{gamma_v}{A numeric vector of regression parameters for the observed
outcome mechanism, \code{Y* | Y}
(observed outcome, given the true outcome) ~ \code{Z} (misclassification
predictor matrix). In matrix form, the gamma parameter matrix rows
correspond to parameters for the \code{Y* = 0}
observed outcome, with the dimensions of \code{Z}.
In matrix form, the gamma parameter matrix columns correspond to the true outcome categories
\eqn{j = 1, \dots,} \code{n_cat}. The numeric vector \code{gamma_v} is
obtained by concatenating the gamma matrix, i.e. \code{gamma_v <- c(gamma_matrix)}.}

\item{Z}{A numeric design matrix.}

\item{obs_Y_matrix}{A numeric matrix of indicator variables (0, 1) for the observed
outcome \code{Y*}. Rows of the matrix correspond to each subject. Columns of
the matrix correspond to each observed outcome category. Each row should contain
exactly one 0 entry and exactly one 1 entry.}

\item{w_mat}{Matrix of E-step weights obtained from \code{w_j}.}

\item{sample_size}{An integer value specifying the number of observations in the sample.
This value should be equal to the number of rows of the design matrix, \code{Z}.}

\item{n_cat}{The number of categorical values that the true outcome, \code{Y},
and the observed outcome, \code{Y*} can take.}
}
\value{
\code{q_beta_f} returns the negative value of the expected log-likelihood function,
\eqn{Q_{\gamma} = \sum_{i = 1}^N \Bigl[\sum_{j = 1}^2 \sum_{k = 1}^2 w_{ij} y^*_{ik} \text{log} \{ \pi^*_{ikj} \}\Bigr]},
at the provided inputs.
}
\description{
Objective function of the form:
\eqn{Q_{\gamma} = \sum_{i = 1}^N \Bigl[\sum_{j = 1}^2 \sum_{k = 1}^2 w_{ij} y^*_{ik} \text{log} \{ \pi^*_{ikj} \}\Bigr]}.
Used to obtain estimates of \eqn{\gamma} parameters.
}
\examples{
\dontrun{
set.seed(123)
n <- 1000
n_cat <- 2

ones <- rep(1, n)
x <- rnorm(n)
X <- matrix(c(ones, x), nrow = n, byrow = FALSE)
z <- rgamma(n, shape = 1)
Z <- matrix(c(ones, z), nrow = n, byrow = FALSE)

beta <- matrix(c(1, -2), ncol = 1)
gamma <- matrix(c(.5, 1, -.5, -1), nrow = 2, byrow = FALSE)

probabilities <- pi_compute(beta, X, n, n_cat = 2)
conditional_probabilities <- pistar_compute(gamma, Z, n, n_cat = 2)

true_Y <- rep(NA, n)
for(i in 1:n){
  true_Y[i] = which(rmultinom(1, 1, probabilities[i,]) == 1)
}
pistar_matrix_labels <- rep(1:n_cat, each = n)
obs_Y <- rep(NA, n)
for(i in 1:n){
 true_j = true_Y[i]
 obs_Y[i] = which(rmultinom(1, 1,
                            conditional_probabilities[c(i, n + i), true_j]) == 1)
 }

obs_Y_reps <- matrix(rep(obs_Y, n_cat), nrow = n, byrow = FALSE)
category_matrix <- matrix(rep(1:n_cat, each = n), nrow = n, byrow = FALSE)
obs_Y_matrix <- 1 * (obs_Y_reps == category_matrix)

e_step_weights <- w_j(ystar_matrix = obs_Y_matrix,
                      pistar_matrix = conditional_probabilities,
                      pi_matrix = probabilities,
                      sample_size = n, n_cat = n_cat)

start_values <- c(1, 1, 1, 1)

estimate_gamma <- optim(par = start_values, fn = q_gamma_f,
                        Z = Z, obs_Y_matrix = obs_Y_matrix,
                        w_mat = e_step_weights,
                        sample_size = n, n_cat = n_cat,
                        method = "BFGS",
                        control = list(maxit = 5))
estimate_gamma$par

q_gamma_f(gamma_v = estimate_gamma$par,
          Z = Z, obs_Y_matrix = obs_Y_matrix,
          w_mat = e_step_weights,
          sample_size = n, n_cat = n_cat)
}
}
