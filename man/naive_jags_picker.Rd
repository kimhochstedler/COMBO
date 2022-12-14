% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/naive_jags_picker.R
\name{naive_jags_picker}
\alias{naive_jags_picker}
\title{Set up a Naive Logistic Regression \code{jags.model} Object for a Given Prior}
\usage{
naive_jags_picker(
  prior,
  sample_size,
  dim_x,
  n_cat,
  Ystar,
  X,
  beta_prior_parameters,
  number_MCMC_chains,
  naive_model_file
)
}
\arguments{
\item{prior}{character string specifying the prior distribution for the naive
\eqn{\beta} parameters. Options are \code{"t"},
\code{"uniform"}, \code{"normal"}, or \code{"dexp"} (double Exponential, or Weibull).}

\item{sample_size}{An integer value specifying the number of observations in the sample.}

\item{dim_x}{An integer specifying the number of columns of the design matrix of the true outcome mechanism, \code{X}.}

\item{n_cat}{An integer specifying the number of categorical values that the true outcome, \code{Y},
and the observed outcome, \code{Y*} can take.}

\item{Ystar}{A numeric vector of indicator variables (1, 2) for the observed
outcome \code{Y*}. The reference category is 2.}

\item{X}{A numeric design matrix for the true outcome mechanism.}

\item{beta_prior_parameters}{A numeric list of prior distribution parameters
for the \eqn{\beta} terms. For prior distributions \code{"t"},
\code{"uniform"}, \code{"normal"}, or \code{"dexp"}, the first element of the
list should contain a matrix of location, lower bound, mean, or shape parameters,
respectively, for \eqn{\beta} terms.
For prior distributions \code{"t"},
\code{"uniform"}, \code{"normal"}, or \code{"dexp"}, the second element of the
list should contain a matrix of shape, upper bound, standard deviation, or scale parameters,
respectively, for \eqn{\beta} terms.
For prior distribution \code{"t"}, the third element of the list should contain
a matrix of the degrees of freedom for \eqn{\beta} terms.
The third list element should be empty for all other prior distributions.
All matrices in the list should have dimensions \code{dim_x} X \code{n_cat}, and all
elements in the \code{n_cat} column should be set to \code{NA}.}

\item{number_MCMC_chains}{An integer specifying the number of MCMC chains to compute.}

\item{naive_model_file}{A .BUG file and used
for MCMC estimation with \code{rjags}.}
}
\value{
\code{naive_jags_picker} returns a \code{jags.model} object for a naive
logistic regression model predicting the potentially misclassified \code{Y*}
from the predictor matrix \code{x}. The object includes the specified
prior distribution, model, number of chains, and data.
}
\description{
Set up a Naive Logistic Regression \code{jags.model} Object for a Given Prior
}
\examples{
\dontrun{
set.seed(123)
n <- 100
x_mu <- 0
x_sigma <- 1
z_shape <- 1

true_beta <- matrix(c(1, -2), ncol = 1)
true_gamma <- matrix(c(.5, 1, -.5, -1), nrow = 2, byrow = FALSE)

my_data <- COMBO_data(sample_size = n,
                      x_mu = x_mu, x_sigma = x_sigma,
                      z_shape = z_shape,
                      beta = true_beta, gamma = true_gamma)

obs_Y = my_data[["obs_Y"]]
X = my_data[["x_design_matrix"]]

unif_lower_beta <- matrix(c(-5, -5, NA, NA), nrow = 2, byrow = TRUE)
unif_upper_beta <- matrix(c(5, 5, NA, NA), nrow = 2, byrow = TRUE)

beta_prior_parameters <- list(lower = unif_lower_beta, upper = unif_upper_beta)

modelstring = naive_model_picker(prior = "uniform")
temp_model_file = tempfile()
tmps = file(temp_model_file, "w")
cat(modelstring, file = tmps)
close(tmps)

jags_model_object <- naive_jags_picker(prior = "uniform",
                                       sample_size = n,
                                       dim_x = ncol(X),
                                       n_cat = 2,
                                       Ystar = obs_Y, X = X,
                                       beta_prior_parameters = beta_prior_parameters,
                                       number_MCMC_chains = 1,
                                       naive_model_file = temp_model_file)
}
}
