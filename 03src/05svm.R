
# svm

set.seed(1)
train

svm_model <- svm(type ~ ., train[,!colnames(train) %in% c("id")], gamma = 1, cost = 2)


svm_result <- predict(svm_model, newdata = valid[,!colnames(valid) %in% c("type")])



confusionMatrix(svm_result, valid$type)


# 최적 하이퍼 파라메터 값 찾기

obj <- tune.svm(type~., data = train, gamma = 2^(-2:2), cost = 2^(1:5))

obj
summary(obj)
plot(obj)
