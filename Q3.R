# STAT580 Project1
# cheese data Q3: discriminant analysis


# Load necessary libraries
library(MASS)       # For lda()
library(caret)      # For data splitting and evaluation
library(ggpubr)     # For normality checks (Shapiro)
library(biotools)   # For Box's M test

# data input & EDA
cheese_data = read.csv("cheeseThermophysical.csv")
head(cheese_data)
table(cheese_data$texture)# mild unbalanced
table(cheese_data$texture)/length(cheese_data$ID)# prior prob.

# Convert target to factor if not already
cheese_data$texture <- as.factor(cheese_data$texture)

# Example structure
# str(cheese_data)
# 'data.frame':	130 obs. of  7 variables:
#  $ texture  : Factor w/ 4 levels
#  $ G80   : num
#  $ vLTmax: num
#  $ vCO   : num
#  $ Fmax  : num
#  $ FD    : num
#  $ FO    : num


# ----------------------------------------
# 1. Check Assumptions
# ----------------------------------------

# 1.1 Normality check for each feature within each group
features <- c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")
for (f in features) {
  cat("\nShapiro test for", f, "by group:\n")
  print(by(cheese_data[[f]], cheese_data$texture, shapiro.test))
}
# all p-value>0.05, cannot reject H0(normality), conclude that data statisfies normality assumption.
# G80-Pasta Filata, vLTmax-Soft, VCO-Pasta Filata <0.05

# 1.2 Box's M test for equality of covariance matrices
boxM_result <- boxM(cheese_data[, features], cheese_data$texture)
print(boxM_result)
# H0: the observed covariance matrices for the dependent variables are equal across groups
# all p-value>0.05, cannot reject H0, conclude that covariance matrices are equal

# ----------------------------------------
# 2. Train-Test Split
# ----------------------------------------
set.seed(615)
train_index <- createDataPartition(cheese_data$texture, p = 0.7, list = FALSE)
train_data <- cheese_data[train_index, ]
test_data  <- cheese_data[-train_index, ]
head(train_data)
table(train_data$texture)
head(test_data)
table(test_data$texture)

# ----------------------------------------
# 3. Fit LDA Model
# ----------------------------------------
lda_model <- lda(texture ~ G80+vLTmax+vCO+Fmax+FD+FO, data = train_data)

# Model summary
print(lda_model)

# extract parameters
mu <- lda_model$means                    # group mean
pi_k <- lda_model$prior                  # prior prob.
Sigma <- lda_model$scaling               # LDA
cov_pooled <- lda_model$svd             # MASS::lda

# linear discriminant functions needs sum*mu
# here we compute by solve():
X <- train_data[, c("G80", "vLTmax", "vCO", "Fmax", "FD", "FO")]
Sigma_pool <- cov(X)                    # 
inv_Sigma <- solve(Sigma_pool)          # sum

# discriminant function
coefs <- lapply(1:nrow(mu), function(i) {
  mu_k <- mu[i, ]
  a <- as.numeric(inv_Sigma %*% mu_k)
  b <- -0.5 * t(mu_k) %*% inv_Sigma %*% mu_k + log(pi_k[i])
  list(name = rownames(mu)[i], intercept = as.numeric(b), coefs = a)
})
coefs

feature_names <- colnames(mu)

for (group in coefs) {
  cat(paste0("\nDiscriminant function for group: ", group$name, "\n"))
  cat(sprintf("d_%s(x) = %.3f", group$name, group$intercept))
  for (j in seq_along(group$coefs)) {
    cat(sprintf(" + %.3f * %s", group$coefs[j], feature_names[j]))
  }
  cat("\n")
}

# ----------------------------------------
# 4. Predict on Test Set
# ----------------------------------------
lda_pred <- predict(lda_model, test_data)

# View first few predictions
head(lda_pred$class)

# levels
# str(test_data$texture)
levels(test_data$texture)

# ----------------------------------------
# 5. Evaluate the Model
# ----------------------------------------
# method 1: Resubstitution
# ----------------------------------------
conf_matrix <- confusionMatrix(lda_pred$class, test_data$texture)
print(conf_matrix)

# Optionally visualize
plot(lda_model)

# dataframe
cm_df <- as.data.frame(conf_matrix$table)
colnames(cm_df) <- c("Predicted", "Actual", "Freq")

# hot
ggplot(data = cm_df, aes(x = Actual, y = Predicted, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), size = 6, color = "black") +
  scale_fill_gradient(low = "#e0f3f8", high = "#08589e") +
  labs(title = "Confusion Matrix (Test Set)", x = "Actual Texture", y = "Predicted Texture") +
  theme_minimal(base_size = 14)

# ----------------------------------------
# method 2: 10-fold Cross-Validation
# ----------------------------------------
# factor levels renamed (delete space)
levels(cheese_data$texture) <- make.names(levels(cheese_data$texture))
levels(train_data$texture) <- make.names(levels(train_data$texture))

# new levels
levels(cheese_data$texture)
levels(train_data$texture)

set.seed(615)
train_control <- trainControl(
  method = "cv", 
  number=10,
  savePredictions = "all",
  classProbs = TRUE)
lda_cv_model <- train(
  texture ~ G80+vLTmax+vCO+Fmax+FD+FO,
  data = train_data,
  method = "lda",
  trControl = train_control
)

# Model summary
print(lda_cv_model)

# Accuracy under cross-validation
cat("\nCross-Validated Accuracy:\n")
print(lda_cv_model$results)

# Confusion Matrix
predictions <- lda_cv_model$pred
true_levels <- levels(cheese_data$texture)
pred <- factor(predictions$pred, levels = true_levels)
obs  <- factor(predictions$obs,  levels = true_levels)
conf_matrix <- confusionMatrix(pred, obs)
print(conf_matrix)

library(reshape2)

# confusion Matrix data frame
conf_table <- as.data.frame(conf_matrix$table)

# heat map
ggplot(conf_table, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), color = "black", size = 5) +
  scale_fill_gradient(low = "#F0F8FF", high = "#4682B4") +
  labs(title = "Confusion Matrix Heatmap", x = "Actual Texture", y = "Predicted Texture") +
  theme_minimal()


