# xgboost


data.train <- xgb.DMatrix(data = data.matrix(train[, !colnames(train) %in% c("id","type")]), label = train$type)
data.valid <- xgb.DMatrix(data = data.matrix(valid[, !colnames(valid) %in% c("id","type")]))

str(train)

parameters <- list(
  
  # General Parameters
  booster            = "gbtree",      
  silent             = 0,           
  
  # Booster Parameters
  eta                = 0.03,              
  gamma              = 0.7,                 
  max_depth          = 10,                
  min_child_weight   = 2,            
  subsample          = .8,                 
  colsample_bytree   = .8,                
  colsample_bylevel  = 1,          
  lambda             = 1,    
  alpha              = 0,       
  
  # Task Parameters
  objective          = "multi:softprob",   # default = "reg:linear" , "softmax", softprob
  eval_metric        = "logloss",          # merror , logloss
  num_class          = length(unique(train$type)) + 1, # 클래스 갯수
  seed               = 1,                 # reproducability seed
  tree_method        = "hist",
  grow_policy        = "lossguide",
  
  print_every_n      = 1,
  verbose            = 1
)

parameters

xgb_model <- xgb.train(parameters, data.train, nrounds = 350)


xgb_pred <- predict(xgb_model, data.valid)
xgb_pred

confusionMatrix(as.factor(xgb_pred), as.factor(as.integer(valid$type))) # 0.872

xgb.importance(colnames(train[, !colnames(valid) %in% c("type")]), model = xgb_model) %>% kable()

xgb.imp <- xgb.importance(colnames(train[, !colnames(valid) %in% c("type","id")]), model = xgb_model)

xgb.ggplot.importance(importance_matrix = xgb.imp)





# softpob으로 설정하고 matrix 아래 코드를 실행해주면 클래스별로 prob을 확인할 수 있다.

xgb_pred <- predict(xgb_model, data.valid)
xgb_pred_proba = matrix(xgb_pred, ncol = (length(unique(train$type)) + 1) , byrow = T)[,-1] 
colnames(xgb_pred_proba) = col


xgb_pred_proba = as.data.frame(xgb_pred_proba)
xgb_pred_proba$id = o_test$id

xgb_pred_proba = xgb_pred_proba[,c(20,1:19)]

fwrite(xgb_pred_proba, "./06submission/xgb/xgb-pred5.csv")










# 그리드 서치 - 하이퍼 파라미터 찾기

searchGridSubCol <- expand.grid(subsample = c(0.5, 0.7, 0.9), 
                                colsample_bytree = c(0.5, 0.7, 0.9),
                                max_depth = c(5, 7, 10),
                                min_child = seq(1), 
                                eta = c(0.03, 0.05, 0.1)
)

ntrees <- 150

system.time(
  rmseErrorsHyperparameters <- apply(searchGridSubCol, 1, function(parameterList){
    
    #Extract Parameters to test
    currentSubsampleRate <- parameterList[["subsample"]]
    currentColsampleRate <- parameterList[["colsample_bytree"]]
    currentDepth <- parameterList[["max_depth"]]
    currentEta <- parameterList[["eta"]]
    currentMinChild <- parameterList[["min_child"]]
    xgboostModelCV <- xgb.cv(data =  data.train, nrounds = ntrees, nfold = 5, showsd = TRUE, 
                             metrics = "rmse", verbose = TRUE, "eval_metric" = "rmse",
                             "objective" = "reg:linear", "max.depth" = currentDepth, "eta" = currentEta,                               
                             "subsample" = currentSubsampleRate, "colsample_bytree" = currentColsampleRate
                             , print_every_n = 10, "min_child_weight" = currentMinChild, booster = "gbtree",
                             early_stopping_rounds = 10)
    
    xvalidationScores <- as.data.frame(xgboostModelCV$evaluation_log)
    rmse <- tail(xvalidationScores$test_rmse_mean, 1)
    trmse <- tail(xvalidationScores$train_rmse_mean,1)
    output <- return(c(rmse, trmse, currentSubsampleRate, currentColsampleRate, currentDepth, currentEta, currentMinChild))}))

rmseErrorsHyperparameters

output <- as.data.frame(t(rmseErrorsHyperparameters))
varnames <- c("TestRMSE", "TrainRMSE", "SubSampRate", "ColSampRate", "Depth", "eta", "currentMinChild")
names(output) <- varnames
output