rm(list = ls())


o_train = read_csv("./01original-data/train.csv")
o_test = read_csv("./01original-data/test.csv")
submission = read_csv("./01original-data/sample_submission.csv")
col = colnames(submission)[-1]
o_train$type = factor(o_train$type, level = col)




##################################################################################
# 이상치 제거 #
##################################################################################

# test 데이터셋의 이상치의 기준을 확인

# 실제 제출하고싶을때.
train = o_train
valid = o_test

valid %>% subset(select = -c(id,fiberID)) %>% summary() 
valid %>% filter(petroMag_g < 0 ) %>% as.data.frame()

train = o_train
train = as.data.frame(train)


for(type_class in levels(train$type)){
  print("\n\n")
  print(type_class)
  train %>% filter(type == type_class) %>% subset(select = -c(id,type,fiberID)) %>% summary() %>% print
} 


train2 = data.frame()
for(type_class in levels(train$type)){
  print("\n\n")
  print(type_class)
  temp = train %>% filter(type == type_class) %>% subset(select = -c(id,type,fiberID)) 
  id_col = train %>% filter(type == type_class) %>% select(id,type,fiberID)
  temp[temp > 300] = NA
  temp[temp < -300] = NA
  temp = cbind(id_col, temp)

  train2 = rbind(train2,temp)
}
train2

for(type_class in levels(train2$type)){
  print("\n\n")
  print(type_class)
  train2 %>% filter(type == type_class) %>% subset(select = -c(id,type,fiberID)) %>% summary() %>% print
} 

train2[is.na(train2),] %>% nrow # 402개의 이상치 검출
colSums(is.na(train2))

train3 = na.omit(train2)
train3 %>% summary

train3 = train3 %>% arrange(id)
colSums(is.na(train3))


train = train3









train %>% colnames()

## train 데이터와 test 데이터 병합후 더미변수화 진행
train_d = train
valid_d = valid

tr_type = train_d$type
train_d$type = NULL

train_d %>% colnames()
valid_d %>% colnames()

train_d %>% nrow()
valid_d %>% nrow()

merge_d = rbind(train_d, valid_d)
merge_d %>% nrow



library(caret)

merge_d$fiberID = as.factor(merge_d$fiberID)
dummy_col = merge_d[,c("id","fiberID")]

dummy <- dummyVars(" ~ .", data=dummy_col)
newdata <- data.frame(predict(dummy, newdata = dummy_col)) 

merge_d$fiberID = NULL
newdata$id = NULL

merge_d = cbind(merge_d, newdata)

merge_d %>% colnames() 

train = merge_d[1:nrow(train_d),]
train$type = tr_type

valid = merge_d[(nrow(train_d) + 1):(nrow(merge_d)),]

ncol(train)
ncol(valid)

#fwrite(train, "./02preprocessing-data/train3.csv")
#fwrite(valid, "./02preprocessing-data/test3.csv")

# 
# 
# 
# o_train = train3
# 
# o_train %>% select(-type) %>% cor() %>% 
#   corrplot.mixed(upper = "ellipse", tl.cex=.8, tl.pos = 'lt', number.cex = .8)
# 
# o_train$type = factor(o_train$type, level = col)
# 
# 
# # o_train %>% select(-type) %>%
# #   corrgram(lower.panel=panel.shade, upper.panel=panel.ellipse)
# 
# 
# 
# set.seed(1)
# inTrain <- createDataPartition(o_train$type, p=.9, list = F)
# 
# 
# 
# train <- o_train[inTrain,]
# str(train)
# valid <- o_train[-inTrain,]
# rm(inTrain)
# 
#fwrite(train3, "./02preprocessing-data/train2.csv")



## valid data dummy!
# 
# valid$fiberID = as.factor(valid$fiberID)
# dummy_col2 = valid[,c("id","fiberID")]
# 
# dummy2 <- dummyVars(" ~ .", data=dummy_col2)
# newdata2 <- data.frame(predict(dummy2, newdata = dummy_col2)) 
# 
# valid$fiberID = NULL
# newdata2$id = NULL
# 
# valid = cbind(valid, newdata2)

###############################################################


#train %>% skim() %>% kable()

# train %>% select(-type) %>% cor() %>% 
#   corrplot.mixed(upper = "ellipse", tl.cex=.8, tl.pos = 'lt', number.cex = .8)

# train %>% select(-type) %>%
#   corrgram(lower.panel=panel.shade, upper.panel=panel.ellipse)








## 내부 검증

## partitioning

set.seed(1)
inTrain <- createDataPartition(train$type, p=.9, list = F)

train <- train[inTrain,]
valid <- train[-inTrain,]
rm(inTrain)

train %>% group_by(type) %>% count()
train %>% nrow  + valid %>% nrow

