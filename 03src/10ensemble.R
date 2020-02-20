library(data.table)

model1 = read_csv("./06submission/rf/rf-pred5.csv")
model2 = read_csv("./06submission/xgb/xgb-pred6.csv")

#ensem = (model1[,2:ncol(model1)] + model2[,2:ncol(model2)] ) /2 
ensem = (model1[,2:ncol(model1)] * 0.35 + model2[,2:ncol(model2)] * 0.65) 
ensem$id = o_test$id

ensem = ensem[,c(ncol(ensem),1:(ncol(ensem)-1))]

fwrite(ensem, "./06submission/ensemble/ensem10.csv")





model1 = read_csv("./06submission/rf/rf-pred2.csv")
model2 = read_csv("./06submission/xgb/xgb-pred5.csv")
model3 = read_csv("./06submission/lgb/lgb-pred2.csv")

ensem = (model1[,2:ncol(model1)] + model2[,2:ncol(model2)] + model3[,2:ncol(model3)]) / 3
ensem$id = o_test$id

ensem = ensem[,c(ncol(ensem),1:(ncol(ensem)-1))]

fwrite(ensem, "./06submission/ensemble/ensem4.csv")



