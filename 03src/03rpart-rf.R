
## decision tree
set.seed(1)

rpart_model <- rpart(type~.,  train[,!colnames(train) %in% c("id")])



#rpart.plot(rpart_model)
#visTree(rpart_model)


#fancyRpartPlot(rpart_model)

rpart_result <- predict(rpart_model, newdata = valid[,!colnames(valid) %in% c("type")], type='class')
rpart_result_proba <- predict(rpart_model, newdata = valid[,!colnames(valid) %in% c("type")], type ="prob")

confusionMatrix(rpart_result, as.factor(valid$type))  # 0.707

rpart_result_proba

varImp(rpart_model) %>% kable()








## randomforest
set.seed(1)

rf_model <- randomForest(type ~., train[,!colnames(train) %in% c("id")])

## 병렬 컴퓨팅 시도 - 실패?

registerDoMC(20) #number of cores on the machine
darkAndScaryForest <- foreach(y=seq(10), .combine=combine ) %dopar% {
  set.seed(1) # not really needed
  rf <- randomForest(type ~., train[,!colnames(train) %in% c("id")])
}

rf_multi_result <- predict(rf, newdata = valid[,!colnames(valid) %in% c("type")])

##




rf_result <- predict(rf_model, newdata = valid[,!colnames(valid) %in% c("type")])
rf_result_proba <- predict(rf_model, newdata = valid[,!colnames(valid) %in% c("type")], type = "prob")

rf_result
rf_result_proba

confusionMatrix(rf_result, valid$type) # 0.8804

varImp(rf_model) %>% kable()
varImpPlot(rf_model)



LogLoss=function(actual, predicted)
{
  result=-1/length(actual)*(sum((actual*log(predicted)+(1-actual)*log(1-predicted))))
  return(result)
}

LogLoss(rf_result_proba, valid)




# rf - tuning

x = train %>% select(-c(type,id))
y = train[,"type"]

control <- trainControl(method='repeatedcv', 
                        number=10, 
                        repeats=3)
#Metric compare model is Accuracy
metric <- "Accuracy"
set.seed(1)
#Number randomely variable selected is mtry
mtry <- sqrt(ncol(x))
tunegrid <- expand.grid(.mtry=mtry)
rf_default <- train(type~. , 
                    data=train, 
                    method='rf', 
                    metric='Accuracy', 
                    tuneGrid=tunegrid, 
                    trControl=control)
print(rf_default)


