#����˵�
#���i heplots �M��A�ޥΨ䤤�����
require(heplots)

#�ݬݻ�����
?VocabGrowth

#��ƨ̧ǬO�b8,9,10,11�~�Ůɪ����q��
data(VocabGrowth)
dta <- VocabGrowth

#�e36���O�k�͡A��28���O�k��
dta$id <- c(1:64)
dta$gender <- factor(c(rep(1,36),rep(2,28)))

#�˵���Ʈ榡�P�e����
#�{������9.1
head(dta)
str(dta)


#���Jreshape2�M��A��ʸ�ƱƦC�Ϊ�
require(reshape2)
dtal <- melt(dta, variable.name ='gradename',  value.name = 'score',id=c('id','gender'))

#��~�s�y�X�ӡA�ݤ@�U�ثe���
dtal$grade <- as.numeric(substr(dtal$gradename, 6, 7))
#�{������9.2
head(dtal)

#�ݥ|�i�������ƻP�ܲ��ơA�k�k���I�t��
#�{������9.3
aggregate(score ~ grade+gender, data = dtal, mean)
aggregate(score ~ grade+gender, data = dtal, sd)

#�ǳ�ø�ϡA���Jggplot2�A�O���U�ثe�t��D�D
require(ggplot2)
old <- theme_set(theme_bw())

#ø�s���P�ʧO�|�i��
#���y�y�վ�@�U�ϡA�K�o��������
#��9.1
pd <- position_dodge(width = .2)
ggplot(data = dtal, aes(x = grade, y = score, shape = gender)) +
 stat_summary(fun.data = 'mean_cl_boot', size = 1, position = pd) +
 stat_summary(fun.y = mean, geom = 'line', aes(group = gender), position = pd) +
 guides(shape = guide_legend(title = '', reverse = TRUE)) +
 labs(x = '�~��', y = '�r�J����') +
 theme(legend.position = c(.9, .9))


#����ܨk�ʤ��R
dtal_M <- subset(dtal, gender == 1)

#�Q�� moment�M��ݬݰ��A�P�p��
#�{������9.4
require(moments)
aggregate(score ~ grade, data = dtal_M, skewness)
aggregate(score ~ grade, data = dtal_M, kurtosis)

#���i car�A�ݥ|�i�������
#��9.2
require(car)
densityPlot(score ~ gradename, data = dtal_M, xlab = '����',ylab='���v',adjust=2)

#�ݬݭӧO��ơA�e�W�j�k�u�ðt�W�϶�
#��9.3
ggplot(data = dtal_M, aes(x = grade, y = score)) +
 geom_line(aes(group = id), linetype = 'dotted') +
 stat_summary(fun.data = 'mean_cl_boot') +
 stat_smooth(method = 'loess') +
 labs(x = '�~��', y = '�r�J����')

#�ӧO�j�k�u 
#��9.4
ggplot(data = dtal_M, aes(x = grade, y = score)) +
 stat_smooth(aes(group = id), method = 'lm', se = F, color = 'gray') +
 geom_point(color = 'gray') +
 labs(x = '�~��', y = '�r�J����')

#�N�~�Ÿm��
dtal_M$grade_c <- scale(dtal_M$grade, scale = F)

#���Jnlme�A�ǳư��C�ӤH���j�k�u
require(nlme)
m1 <- lmList(score ~ grade_c | id, data = dtal_M)

#�������s�ȡC�o�ӥ\��Ӧ�car�M��
#��9.5
dataEllipse(coef(m1)[, 1], coef(m1)[, 2], levels = c(.68, .95), pch = 19,
            col = 'black', id.n = 2, xlab = '�I�Z���p��', 
            ylab = '�ײv���p��')



#��b�����ҫ��i�H�����]�����R���l�ҫ��A�ڭ̥H lavaan �i����R
library(lavaan)

#����ܨk�ʤ��R
dta_M <- subset(dta, gender == 1)

#���ոլݽu�ʼҫ�
growth1 <- '
intercept =~ 1*grade8+1*grade9+1*grade10+1*grade11
slope =~ 0*grade8+1*grade9+2*grade10+3*grade11
'
#�{������9.5, 9.6
rslt1 <- growth(model = growth1, data = dta_M)
summary(rslt1, fit.measures = T)


#�ոլݤG���ҫ�
growth2 <- '
intercept =~ 1*grade8+1*grade9+1*grade10+1*grade11
linear =~ 0*grade8+1*grade9+2*grade10+3*grade11
qudratic =~ 0*grade8+1*grade9+4*grade10+9*grade11
'

#�{������9.7
rslt2 <- growth(model = growth2, data = dta_M)
summary(rslt2, fit.measures = T)
anova(rslt1, rslt2)


#�]�t�Ϊ��]������b�����ҫ��A�Ϊ����T�w
growth3 <- '
intercept =~ 1*grade8+1*grade9+1*grade10+1*grade11
shape =~ 0*grade8+grade9+grade10+1*grade11
'

#�{������9.8
rslt3 <- growth(model = growth3, data = dta_M)
summary(rslt3, fit.measures=T)

rslt <- c(rslt1,rslt2,rslt3)
lapply(rslt, function(x) fitMeasures(x,c('chisq','df','pvalue','rmsea','srmr','tli','cfi','aic')))


##�]�A�@�ܶq����b�����ҫ�
#�ڭ̿�ܤG���ҫ�
#�i�@�B�ݬݩʧO��I�Z�P�Ϊ����v�T�C
#���ݬݤk�ĸ�ưt�A���ΡC
dta_F <- subset(dta, gender == 2)

rslt22 <- growth(model = growth2, data=dta_F)
summary(rslt22, fit.measures = T)

#�N�ʧO�ܦ� 0,1 �������ܶ�
dta$g <- ifelse(dta$gender ==1,1,0)

#�]�t�Ϊ��Ѽƪ���b�����ҫ��A���ʧO�v�T�I�Z�P�Ϊ��ѼơC
growth4 <- '
intercept =~ 1*grade8+1*grade9+1*grade10+1*grade11
linear =~ 0*grade8+1*grade9+2*grade10+3*grade11
qudratic =~ 0*grade8+1*grade9+4*grade10+9*grade11
intercept~g
linear~g
qudratic~g
'

#�{������9.9
rslt4 <- growth(model = growth4, data = dta, fixed.x = T)
summary(rslt4, fit.measures = T)


#�ק�ҫ��A�⤣��۪�linear, quadratic�ܲ��Ʈ���
growth5 <- '
intercept =~ 1*grade8+1*grade9+1*grade10+1*grade11
linear =~ 0*grade8+1*grade9+2*grade10+3*grade11
qudratic =~ 0*grade8+1*grade9+4*grade10+9*grade11
intercept~g
linear~g
qudratic~g
linear~~0*linear
qudratic~~0*qudratic
'

#�{������9.10
rslt5 <- growth(model = growth5, data = dta, fixed.x = T)
summary(rslt5, fit.measures = T)
anova(rslt4,rslt5)


#�����ڸ�ƻP�w���ȥ���
#�p���ڥ�����
dest <- dreal <- aggregate(score ~ grade+gender, data = dtal, mean)
dreal$type <- c(rep('��ڨk',4),rep('��ڤk',4))
g <- dreal$gender==1
t <- (dreal$grade-8)

#�p��w����
est <- (1.156+.003*g)+(1.714-.530*g)*t+(-.329+.195*g)*t^2
dest$type <- c(rep('�w���k',4),rep('�w���k',4))
dest$score <- est
dall <- rbind(dreal,dest)

#�e��
#��9.6
xyplot(score ~ grade, data = dall, group = type,
       lty = c(2,2,1,1), type = 'l',
       grid = T, xlab = '�~��', ylab = '�r�J���ƥ���', 
       auto.key = list(columns = 4),
       panel = function(...){ 
         panel.xyplot(...) 
       }) 

#��^ggplot2�¥D�D
theme_set(old)