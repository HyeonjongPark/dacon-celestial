
# h2o

h2o.init()

h2o.train <- as.h2o(train[, !colnames(train) %in% c("id")])

h2o.valid <- as.h2o(valid[, !colnames(valid) %in% c("id")])





h2o.model <- h2o.deeplearning(x = setdiff(names(train), c("id","type")),
                              y = "type",
                              training_frame = h2o.train,
                              # activation = "RectifierWithDropout", # algorithm
                              # input_dropout_ratio = 0.2, # % of inputs dropout
                              # balance_classes = T,
                              # momentum_stable = 0.99,
                              # nesterov_accelerated_gradient = T, # use it for speed
                              epochs = 1000,
                              standardize = TRUE,         # standardize data
                              hidden = c(50,50,50,50),       # 2 layers of 00 nodes each
                              stopping_metric = "logloss",
                              rate = 0.03,                # learning rate
                              seed = 1                # reproducability seed
)



h2o.predictions <- h2o.predict(h2o.model, h2o.valid) %>% as.data.frame()
h2o.predictions = h2o.predictions[,c("predict",col)]


h2o.predictions

confusionMatrix(h2o.predictions$predict, valid$type) # 0.848


h2o.predictions = h2o.predictions[,-1]
h2o.predictions$id = o_test$id 
h2o.predictions = h2o.predictions[,c(20,1:19)]
#fwrite(h2o.predictions, "./06submission/h2o-pred3-1.csv")


#rm(h2o.model, h2o.train, h2o.valid, h2o.predictions)










## h2o + xgboost ensemble => 서버 환경에서 가능


#h2o.init()
h2o.init(nthreads = -1, ip = "127.0.0.1", port = 50003)

# Identify predictors and response
x <- names(train)[which(names(train)!= c("type"))]
x = x[-1]
y <- "type"

# 1.1 Import Data to h2o
train <- as.h2o(train[, !colnames(train) %in% c("id")])
test <- as.h2o(valid[, !colnames(valid) %in% c("id")])

###################
# Specify a grid of XGBoost parameters to search 
###################

# Number of CV folds (to generate level-one data for stacking)
nfolds <- 5

# XGBoost Hyperparamters - see list of parameters to tune here:
eta_opt <- c(0.1,0.01,0.001)
learn_rate_opt <- c(0.01, 0.03)
max_depth_opt <- c(2, 4, 6, 8, 10)
sample_rate_opt <- c(0.5, 0.75, 0.9, 1.0)
col_sample_rate_opt <- c(0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
hyper_params <- list(eta = eta_opt,
                     learn_rate = learn_rate_opt,
                     max_depth = max_depth_opt,
                     sample_rate = sample_rate_opt,
                     col_sample_rate = col_sample_rate_opt)

search_criteria <- list(strategy = "RandomDiscrete",
                        max_models = 3,
                        seed = 1)

xgb_grid <- h2o.grid(algorithm = "xgboost",
                     grid_id = "xgb_grid_gaussian",
                     x = x,
                     y = y,
                     training_frame = train,
                     ntrees = 350, #change, or add to grid search list
                     seed = 1,
                     nfolds = nfolds,
                     fold_assignment = "Modulo",
                     keep_cross_validation_predictions = TRUE,
                     hyper_params = hyper_params,
                     search_criteria = search_criteria)

# Evaluate performance of xgb - not sure why I couldn't get these to work...
# perf_xgb_train <- h2o.performance(xgb_grid)
# perf_xgb_test <- h2o.performance(xgb_grid, newdata = test)
# print("XGB training performance: ")
# print(perf_xgb_train)
# print("XGB test performance: ")
# print(perf_xgb_test)

# Train a stacked ensemble of the 3 XGB grid models
ensemble <- h2o.stackedEnsemble(x = x,
                                y = y,
                                training_frame = train,
                                model_id = "ensemble_xgb_grid_gaussian",
                                base_models = xgb_grid@model_ids)

# Evaluate ensemble performance; also not working for some reason...
# perf_ensemble_train <- h2o.performance(ensemble)
# perf_ensemble_test <- h2o.performance(ensemble, newdata = test)

# Generate predictions on a test set (if neccessary)

h2o.predictions <- h2o.predict(ensemble, test) %>% as.data.frame()
h2o.predictions = h2o.predictions[,c("predict",col)]

h2o.predictions

confusionMatrix(h2o.predictions$predict, valid$type) # 0.848

