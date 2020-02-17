
# svm

set.seed(1)
train

svm_model <- svm(type ~ ., train[,!colnames(train) %in% c("id")], gamma = 1, cost = 2, probability = TRUE)


svm_result <- predict(svm_model, newdata = valid[,!colnames(valid) %in% c("id","type")], probability = TRUE)


confusionMatrix(svm_result, valid$type)

p_svm_model <- parallelSVM(type ~ ., train[,!colnames(train) %in% c("id")], gamma = 1, cost = 2, probability = TRUE)
p_svm_result <- attr(predict(p_svm_model, valid[,!colnames(valid) %in% c("id","type")], probability = TRUE), "probabilities")

p_svm_result%>% class
p_svm_result = as.data.frame(p_svm_result)
p_svm_result = p_svm_result[,col]
p_svm_result$id = o_test$id

p_svm_result %>% head
p_svm_result = p_svm_result[,c(ncol(p_svm_result),1:(ncol(p_svm_result)-1))]

fwrite(p_svm_result, "./06submission/svm/svm-pred1.csv")

# 최적 하이퍼 파라메터 값 찾기

obj <- tune.svm(type~., data = train, gamma = 2^(-2:2), cost = 2^(1:5))

obj
summary(obj)
plot(obj)




