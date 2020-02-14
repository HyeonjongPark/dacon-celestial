
## decision tree
set.seed(1)

rpart_model <- rpart(type~.,  train[,!colnames(train) %in% c("id")])



rpart.plot(rpart_model)
visTree(rpart_model)


fancyRpartPlot(rpart_model)

rpart_result <- predict(rpart_model, newdata = valid[,!colnames(valid) %in% c("type")], type='class')
rpart_result_proba <- predict(rpart_model, newdata = valid[,!colnames(valid) %in% c("type")], type ="prob")

rpart_result_proba

confusionMatrix(rpart_result, as.factor(valid$type))  # 0.707

varImp(rpart_model) %>% kable()








## randomforest

set.seed(1)

rf_model <- randomForest(type ~., train[,!colnames(train) %in% c("id")])

rf_result <- predict(rf_model, newdata = valid[,!colnames(valid) %in% c("type")])
rf_result_proba <- predict(rf_model, newdata = valid[,!colnames(valid) %in% c("type")], type = "prob")

rf_result_proba
rf_result

confusionMatrix(rf_result, valid$type) # 0.8804

varImp(rf_model) %>% kable()
varImpPlot(rf_model)




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


