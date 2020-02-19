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



library(caret)

dummy_col = train[,c("id","fiberID")]

dummy <- dummyVars(" ~ .", data=dummy_col)
newdata <- data.frame(predict(dummy, newdata = dummy_col)) 

train$fiberID = NULL
newdata$id = NULL

train = cbind(train, newdata)

###############################################################


#train %>% skim() %>% kable()

# train %>% select(-type) %>% cor() %>% 
#   corrplot.mixed(upper = "ellipse", tl.cex=.8, tl.pos = 'lt', number.cex = .8)

# train %>% select(-type) %>%
#   corrgram(lower.panel=panel.shade, upper.panel=panel.ellipse)



set.seed(1)
inTrain <- createDataPartition(train$type, p=.9, list = F)

train <- train[inTrain,]
valid <- train[-inTrain,]
rm(inTrain)

train %>% group_by(type) %>% count()
train %>% nrow  + valid %>% nrow

