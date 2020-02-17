library(data.table)

e.h2o = read_csv("./06submission/h2o/h2o-pred3.csv")
e.xgb = read_csv("./06submission/xgb/xgb-pred1.csv")

ensem = (e.h2o[,2:ncol(e.h2o)] + e.xgb[,2:ncol(e.xgb)]) / 2
ensem$id = o_test$id

ensem = ensem[,c(ncol(ensem),1:(ncol(ensem)-1))]

fwrite(ensem, "./06submission/ensemble/ensem1.csv")
