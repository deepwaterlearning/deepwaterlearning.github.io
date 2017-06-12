# Project 3 : Kaggle AllState Challenge

library(reshape2)
library(data.table)
library(ggplot2)
library(forcats)
require(scales)
library(ggthemes)
library(dplyr)

library(e1071) 
library(grid)
library(corrgram)
library(corrplot)
library(doSNOW)
library(ipred) 
library(Metrics)
library(plyr)

library(caret)
library(randomForest)
library(monomvn)
library(xgboost) 
library(elasticnet)
library(gbm)
library(kernlab)
library(nnet)
library(rpart)
library(glmnet)

setwd("/Users/intothelight/nycdatascience/deepwaterlearning.github.io/project_03")


train.raw  <- read.csv("data/train.csv", header = TRUE, stringsAsFactors = FALSE)
test.raw  <- read.csv("data/test.csv", header = TRUE, stringsAsFactors = FALSE)

train <- train.raw
test <- test.raw

features.numeric <- paste("cont", 1:14, sep = "")
features.categorical <- paste("cat", 1:116, sep = "")
target.label <- c("loss")
id.column <- c("id")
features <- c(target.label,features.categorical,features.numeric)

train$id <- NULL

# examine the dataset
dim(train)
str(train)
head(train, n = 5)
names(train)
# any na -- nope
sum(is.na(train))

# get numeric columns
numeric_columns <- sapply(train, is.numeric)
train.continuous <- train[,numeric_columns]
# A closer look at continuous variables
summary(train.continuous)
# lets look at both mean and std
sapply(train.continuous, function(cl) list(means=mean(cl,na.rm=TRUE), sds=sd(cl,na.rm=TRUE)))
# Looks like mean of ~.5 and std of ~.2 (already processed)
# Average loss of $3037 with the training set

# examine histograms
df <- melt(train.continuous[,-c(1)]) # remove id column
ggplot(df,aes(x = value, color="gold")) + 
  facet_wrap(~variable,scales = "free") + 
  geom_histogram(bins = 15)

# how skewd is the data
apply(train.continuous[,-c(1)], 2, skewness)
# Well, according to this: The values for asymmetry and kurtosis between -2 and +2 are considered 
#   acceptable in order to prove normal univariate distribution (George & Mallery, 2010) 
# So, maybe only loss needs to be transformed, lets do a density plot on it:
plot(density(train.continuous$loss)) 
# yep, skewed right, lets do a log transform to see what that looks loike
train.continuous$loss <- log1p(train.continuous$loss)
train$loss <- log1p(train$loss)
plot(density(train.continuous$loss))

# correlations
train.continuous.features <- train.continuous
train.continuous.features$id <- NULL
train.continuous.features$loss <-NULL
cor(train.continuous.features)
corrplot(cor(train.continuous.features), type = "full", order="hclust", tl.col = "black", tl.srt = 45)

# (This section only works if we have already made sure to change the character set to factors)

# lets do some histograms on categorical features
# how many do we have?
factor_columns <- sapply(train, is.character)
train.cat <- as.data.frame(lapply(train[,factor_columns], as.factor))
table(factor_columns)["TRUE"]
# 116 categorical, yuck. dont want to do histos of all of them
# get counts of levels
sapply(train.cat, nlevels)
# looks like most have 2, and we start getting a little more after cat73
label <- paste0("cat25: ", nlevels(train.cat$cat25), " levels")
barplot(table(train.cat$cat25),  xlab = label, ylim = c(0, 200000),col = c("blue","black"))
label <- paste0("cat99: ", nlevels(train.cat$cat99), " levels")
barplot(table(train.cat$cat99),  xlab = label, ylim = c(0, 100000),col = c("blue","black"))
label <- paste0("cat109: ", nlevels(train.cat$cat109), " levels")
barplot(table(train.cat$cat109),  xlab = label, ylim = c(0, 150000),col = c("blue","black"))
label <- paste0("cat116: ", nlevels(train.cat$cat116), " levels")
barplot(table(train.cat$cat116),  xlab = label, ylim = c(0, 25000),col = c("blue","black"))



# Below not useful
# cat_factor_counts <- data.frame(sapply(train.cat, nlevels))
# colnames(cat_factor_counts) <- c("level.counts")
# cat_factor_counts[ "variable" ] <- rownames(cat_factor_counts)
# cat_factor_counts.molten <- melt( cat_factor_counts, id.vars="level.counts", value.name="Cat.Variables")
# hist(group_by(cat_factor_counts$level.counts))

data2 <- cat_factor_counts %>% 
  group_by(level.counts) %>% 
  summarise(n = n())
str(data2)
# plot distribution of levels
ggplot(data2,aes(x = factor(""), y = n,fill = forcats::fct_rev(factor(level.counts)))) + 
  geom_bar(position = "fill",stat = "identity") + 
  labs(title = "Level Frequency For 116 Categorical Variables\n", x = "All Categorical Variables", y = "% of vars with specific levels") +
  scale_y_continuous(labels = percent_format())


# clear unused variables
rm(cat_factor_counts,cat_factor_counts.molten,data2,df,train.cat,train.continuous,train.continuous.features)

# lets break our huge set to small train/validate series



############################################################# SAMPLE TESTING ############################

# Use caret to create a 70/30% split of the training data,
# keeping the proportions of the loss class label the 
# same across splits.
set.seed(3183)
# indexes <- createDataPartition(train$loss,     # stratified random samples
#                                times = 5,
#                                p = 0.7,
#                                list = FALSE)
indexes <- sample(nrow(train), size = 2000, replace = FALSE)
train.sample <- train[indexes,]
# First, transform all features to dummy variables.
col_features = names(train.sample)
for (f in col_features) {
  if (class(train.sample[[f]]) == "character") {
    levels <- unique(train.sample[[f]])
    train.sample[[f]] <- as.integer(factor(train.sample[[f]], levels = levels))
  }
}


indexes <- createDataPartition(train.sample$loss,     # stratified random samples
                               times = 1,
                               p = 0.7,
                               list = FALSE)
sample.train <- train.sample[indexes,]
sample.test <- train.sample[-indexes,]

# sample #2
#indexes <- sample(nrow(train), size = 10000, replace = FALSE)
#train.sample2 <- train[indexes,]
# First, transform all features to dummy variables.
# col_features = names(train.sample2)
# for (f in col_features) {
#   if (class(train.sample2[[f]]) == "character") {
#     levels <- unique(train.sample2[[f]])
#     train.sample2[[f]] <- as.integer(factor(train.sample2[[f]], levels = levels))
#   }
# }


# generic maeOn
maeOnLog1pData <- function(predictions,actual){
  result <- Metrics::mae(expm1(actual), expm1(predictions))
  names(result) <- "MAE"
  result
}

# Define cost functions
# Custom MAE metric in caret format
# MAE set up
maeOnLogMetric <- function(data,
                       lev = NULL,
                       model = NULL) {
  out <- Metrics::mae(expm1(data$obs), expm1(data$pred))
  names(out) <- "MAE"
  out
}

maeMetric <- function(data,
                         lev = NULL,
                         model = NULL) {
  out <- Metrics::mae(data$obs,data$pred)
  names(out) <- "MAE"
  out
}


# set up caret to perform 10-fold cross validation repeated 3 
# times and to use a grid search for optimal model hyperparameter
# values: used for all models
train.control <- trainControl(method = "repeatedcv",
                              number = 10,
                              repeats = 3,
                              summaryFunction = maeOnLogMetric,
                              search = "grid")

tune.grid <- expand.grid(eta = c(0.05, 0.075, 0.1),
                         nrounds = c(50, 75, 100),
                         max_depth = 6:8,
                         min_child_weight = c(2.0, 2.25, 2.5),
                         colsample_bytree = c(0.3, 0.4, 0.5),
                         gamma = 0,
                         subsample = 1)




cl <- makeCluster(4, type = "SOCK")

registerDoSNOW(cl)


# eXtreme Gradient Boosting (xgbTree): library(xgboost)
start.time <- Sys.time()

xgbTree_model <- train(loss ~ .,
                  data = sample.train,
                  method = "xgbTree",           # xgbTree, lm
                  metric = "MAE",
                  trControl = train.control,
                  tuneGrid = tune.grid )

end.time <- Sys.time()
xgbTree.time.taken <- end.time - start.time
xgbTree.time.taken


# Random Forest
rf.control <- trainControl(method = "repeatedcv",
                              number = 10,
                              repeats = 3,
                              summaryFunction = maeOnLogMetric,
                              search = "grid")

start.time <- Sys.time()
rf_model <- train(loss ~ .,
                 data = sample.train,
                 method = "rf",           
                 metric = "MAE",
                 trControl = rf.control)
end.time <- Sys.time()
rf.time.taken <- end.time - start.time
rf.time.taken

# Linear Regression (lm)
lm.control <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 3,
                           summaryFunction = maeOnLogMetric,
                           search = "grid")

start.time <- Sys.time()
lm_model <- train(loss ~ .,
                  data = sample.train,
                  method = "lm",
                  metric = "MAE",
                  trControl = lm.control)

end.time <- Sys.time()
lm.time.taken <- end.time - start.time
lm.time.taken

# Neural Networks (nnet)
nn.control <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 3,
                           summaryFunction = maeOnLogMetric,
                           search = "grid")

start.time <- Sys.time()
nn_model <- train(loss ~ .,
                  data = sample.train,
                  method = "nnet",
                  metric = "MAE",
                  trControl = nn.control)

end.time <- Sys.time()
nn.time.taken <- end.time - start.time
nn.time.taken


# Glmnet
glm.control <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 3,
                           summaryFunction = maeOnLogMetric,
                           search = "grid")

start.time <- Sys.time()
glm_model <- train(loss ~ .,
                  data = sample.train,
                  method = "glmnet",
                  metric = "MAE",
                  trControl = glm.control)

end.time <- Sys.time()
glm.time.taken <- end.time - start.time
glm.time.taken



# Bayesian Ridge Regression (bridge): library(monomvn)
# start.time <- Sys.time()
# 
# bridge_model <- train(loss ~ .,
#                        data = train.sample,
#                        method = "bridge",           
#                        metric = "MAE",
#                        trControl = train.control,
#                        tuneGrid = tune.grid)    #Error: The tuning parameter grid should have columns parameter 
# 
# end.time <- Sys.time()
# bridge.time.taken <- end.time - start.time
# bridge.time.taken



# Ridge Regression (ridge): library(elasticnet)
# start.time <- Sys.time()
# 
# ridge_model <- train(loss ~ .,
#                        data = train.sample,
#                        method = "ridge",           
#                        metric = "MAE",
#                        trControl = train.control,
#                        tuneGrid = NULL) #maybe like this:https://quantmacro.wordpress.com/2016/04/26/fitting-elastic-net-model-in-r/
# 
# end.time <- Sys.time()
# ridge.time.taken <- end.time - start.time
# ridge.time.taken




# The lasso (lasso): library(elasticnet)
# start.time <- Sys.time()
# 
# lasso_model <- train(loss ~ .,
#                        data = train.sample,
#                        method = "lasso",           
#                        metric = "MAE",
#                        trControl = train.control,
#                        tuneGrid = tune.grid )
# 
# end.time <- Sys.time()
# lasso.time.taken <- end.time - start.time
# lasso.time.taken








# (rpart): library(rpart) # probably not useful
start.time <- Sys.time()
rpart_model <- train(loss ~ .,
                     data = train.sample,
                     method = "rpart",
                     trControl = train.control)

end.time <- Sys.time()
rpart.time.taken <- end.time - start.time
rpart.time.taken

# Stochastic Gradient Boosting (gbm): library(gbm), library(plyr)



# SVM with Linear Kernel: library(kernlab)




# Neural Network (nnet): library(nnet)

stopCluster(cl)


#### Examine caret's processing results
xgbTree_model
xgbTree_predictions <- predict(xgbTree_model, sample.test)
maeOnLog1pData(xgbTree_predictions,sample.test$loss)
postResample(expm1(xgbTree_predictions),expm1(sample.test$loss))



# rf
rf_model
rf_predictions <- predict(rf_model, sample.test)
maeOnLog1pData(rf_predictions,sample.test$loss)
postResample(expm1(rf_predictions),expm1(sample.test$loss))
##postResample(rf_predictions, sample.test)  # not the correct scoring method


# lm
lm_model
lm_predictions <- predict(lm_model, sample.test)
maeOnLog1pData(lm_predictions,sample.test$loss)
postResample(expm1(lm_predictions),expm1(sample.test$loss))

# nnet
nn_model
nn_predictions <- predict(nn_model, sample.test)
maeOnLog1pData(nn_predictions[,1],sample.test$loss)
postResample(expm1(nn_predictions[,1]),expm1(sample.test$loss))

# glmnet
glm_model
glm_predictions <- predict(glm_model, sample.test)
maeOnLog1pData(glm_predictions,sample.test$loss)
postResample(expm1(glm_predictions),expm1(sample.test$loss))



#  rpart
rpart_model

rpart_predictions <- predict(rpart_model, sample.test)
postResample(rpart_predictions, sample.test)

############### ANOTHER OPTION



start.time <- Sys.time()





end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken




############################################################# END SAMPLE TESTING ############################
# Begin encoding and modeling
setDT(train)
setDT(test)

#y.train = log10(train[,"loss", with = FALSE]+1)[["loss"]]
y.train = train$loss

train[, c("id", "loss") := NULL]
test[, c("id") := NULL]
ntrain = nrow(train)
train.test = rbind(train, test)

# encode option 1
dmy_set = dummyVars("~.", data = train.test, fullRank = TRUE)
train.transformed <- data.frame(predict(dmy_set, newdata = train.test))
x.train = train.transformed[1:ntrain,]
x.test = train.transformed[(ntrain+1):nrow(train.transformed),]
# end encode option 1

# encode option 2
features = names(train)
for (f in features) {
  if (class(train.test[[f]]) == "character") {
    levels <- unique(train.test[[f]])
    train.test[[f]] <- as.integer(factor(train.test[[f]], levels = levels))
  }
}
x.train = train.test[1:ntrain,]
x.test = train.test[(ntrain+1):nrow(train.test),]
# end encode option 2


# create models
bridge_model <- train(x.train,y.train, method='bridge')
lasso_model <- train(x.train,y.train, method='lasso')
rf_model <- train(x.train,y.train, method='rf')
nnet_model <- train(x.train,y.train, method='nnet')
gbm_model <- train(x.train,y.train, method='gbm')

# predict
predictions_bridge <- predict.train(object=bridge_model,x.test,type="raw")
predictions_rf <- predict.train(object=rf_model,x.test,type="raw")
predictions_nnet <- predict.train(object=nnet_model,x.test,type="raw")
predictions_gbm <- predict.train(object=gbm_model,x.test,type="raw")

table(predictions_bridge)
table(predictions_rf)
table(predictions_nnet)
table(predictions_gbm)

# xgb model
dtrain = xgb.DMatrix(as.matrix(x.train), label=y.train)
dtest = xgb.DMatrix(as.matrix(x.test))

xgb_params = list(
  seed = 0,
  colsample_bytree = 0.7,
  subsample = 0.7,
  eta = 0.075,
  objective = 'reg:linear',
  max_depth = 6,
  num_parallel_tree = 1,
  min_child_weight = 1,
  base_score = 7
)

xg_eval_mae <- function (yhat, dtrain){
  y <- getinfo(dtrain, "label")
  err <- mae(exp(y),exp(yhat))
  return (list(metric="error", value=err))
}

# cross validation
res <- xgb.cv(xgb_params,
             dtrain,
             nrounds=750,
             nfold=4,
             early_stopping_rounds = 15,
             print_every_n = 10,
             verbose = 1,
             feval = xg_eval_mae,
             maximize = FALSE)

best_nrounds <- res$best_iteration
cv_mean <- res$evaluation_log$test_error_mean[best_nrounds]
cv_std <- res$evaluation_log$test_error_std[best_nrounds]
cat(paste0('CV-Mean: ', cv_mean, ' ',cv_std))

gbdt <- xgb.train(xgb_params, dtrain, best_nrounds)

loss <- exp(predict(gbdt,dtest))

# print to file





