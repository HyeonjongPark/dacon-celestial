
o_train = read_csv("./01original-data/train.csv")
o_test = read_csv("./01original-data/test.csv")
submission = read_csv("./01original-data/sample_submission.csv")

o_train
o_test
col = colnames(submission)[-1]

o_train %>% skim() %>% kable()

o_train %>% select(-type) %>% cor() %>% 
  corrplot.mixed(upper = "ellipse", tl.cex=.8, tl.pos = 'lt', number.cex = .8)

o_train$type = factor(o_train$type, level = col)


# o_train %>% select(-type) %>%
#   corrgram(lower.panel=panel.shade, upper.panel=panel.ellipse)



set.seed(1)
inTrain <- createDataPartition(o_train$type, p=.9, list = F)



train <- o_train[inTrain,]
str(train)
valid <- o_train[-inTrain,]
rm(inTrain)



train %>% group_by(type) %>% count()


# train = o_train
# valid = o_test