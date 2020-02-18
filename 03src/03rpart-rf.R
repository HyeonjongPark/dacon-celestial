
## decision tree
set.seed(2)

rpart_model <- rpart(type~.,  train[,!colnames(train) %in% c("id")])



#rpart.plot(rpart_model)
#visTree(rpart_model)


#fancyRpartPlot(rpart_model)

rpart_result <- predict(rpart_model, newdata = valid[,!colnames(valid) %in% c("type")], type='class')

confusionMatrix(rpart_result, as.factor(valid$type))  # 0.707

rpart_result_proba <- predict(rpart_model, newdata = valid[,!colnames(valid) %in% c("type")], type ="prob")
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
rf_result_proba <- predict(rf_model, newdata = valid[,!colnames(valid) %in% c("id","type")], type = "prob")

rf_result
rf_result_proba

confusionMatrix(rf_result, valid$type) # 0.8804

varImp(rf_model) %>% kable()
varImpPlot(rf_model)


rf_result_proba = as.data.frame(rf_result_proba)
rf_result_proba$id = o_test$id
rf_result_proba = rf_result_proba[,c(ncol(rf_result_proba),1:(ncol(rf_result_proba)-1))]

fwrite(rf_result_proba, "./06submission/rf-pred1.csv")





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


