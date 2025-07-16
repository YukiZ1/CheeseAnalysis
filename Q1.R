# Question 1 – MANOVA
# List Library
library(tidyverse)   # for data manipulation and visualization
library(car)         # for MANOVA tools and Pillai’s trace
library(ggplot2)     # for plotting
library(dplyr)
library(RRPP)       # for pirwise MANOVA
library(MVN)        # for assessing Multivariate Normality
library(biotools)   # for Box's M test
library(corrplot)

#Load Datasets
cheese <- read.csv("/Users/robertmayne/Documents/STAT 580/cheeseThermophysical.csv", header=TRUE)

# Check structure of the data
# Here we see that the cheese is a character that needs to be converted to a factor.
glimpse(cheese)

# Convert texture to a factor (important for MANOVA)
cheese$texture <- factor(cheese$texture)

# Multivariate Normality

# Subset the dataset to include only samples with the specific textures,ckeeping only the six thermophysical response variables.
# This allows us to assess multivariate normality within this texture group.
hard_data <- subset(cheese, texture == "Hard")[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]
semi_data <- subset(cheese, texture == "Semi-Hard")[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]
pasta_data <- subset(cheese, texture == "Pasta Filata")[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]
soft_data <- subset(cheese, texture == "Soft")[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]

# Run Mardia's test with plot
mvn(hard_data, mvn_test = "mardia")
mvn(semi_data, mvn_test = "mardia")
mvn(pasta_data, mvn_test = "mardia")
mvn(soft_data, mvn_test = "mardia")

# Function to create Q-Q plot of Mahalanobis distances manually
qq_mahalanobis <- function(data, group_name) {
  data <- na.omit(data)
  if (nrow(data) <= ncol(data)) {
    warning(paste("Skipping", group_name, "- not enough observations"))
    return(NULL)
  }
  
  # Manually compute Mahalanobis distances
  center <- colMeans(data)
  cov_matrix <- cov(data) 
  if (det(cov_matrix) == 0) {
    warning(paste("Skipping", group_name, "- singular covariance matrix"))
    return(NULL)
  }
  d2 <- mahalanobis(data, center, cov_matrix)
  theoretical <- qchisq(ppoints(length(d2)), df = ncol(data))
  
  # Create base R plot
  qqplot(theoretical, sort(d2),
         main = paste("Q-Q Plot:", group_name),
         xlab = "Theoretical Quantiles",
         ylab = "Observed Mahalanobis Distances")
  abline(0, 1, col = "red", lwd = 2)
}
# Layout for 2x2 plots
par(mfrow = c(2, 2))

# Run manually for each group
for (group in unique(cheese$texture)) {
  data_subset <- subset(cheese, texture == group)[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]
  qq_mahalanobis(data_subset, group)
}

# Homogeneity of Covariance Matrices
responses <- cheese[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]
# Run Box's M test
boxM(responses, cheese$texture)

# Absence of Multicollinearity
# Correlation matrix
cor(responses)

# # Create correlation matrix
cor_matrix <- round(cor(responses, use = "complete.obs"), 3)  # Rounded to 3 decimals

# Print it nicely with spacing
print(cor_matrix)

# Start MANOVA
# Select thermophysical variables as response
response_vars <- c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")

# Create the MANOVA model
manova_model <- manova(as.matrix(cheese[, response_vars]) ~ texture, data = cheese)
manova_model

# View MANOVA summary using Wilks as the conditions for MANOVA have been met.
summary(manova_model, test = "Wilks")

# Run the multivariate model
manova_rrpp <- lm.rrpp(as.matrix(cheese[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]) ~ texture,
                       data = cheese, iter = 999)

# Run pairwise MANOVA comparisons
pairwise_results <- pairwise(manova_rrpp, groups = cheese$texture)

# Summarize results
summary(pairwise_results)
