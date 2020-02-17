
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
#fwrite(h2o.predictions, "./06submission/h2o-pred3.csv")


#rm(h2o.model, h2o.train, h2o.valid, h2o.predictions)