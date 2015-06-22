
#Ū�ɮסA�o�O�@�몺��r�ɡA�i�H�� notepad �}��
dta <- read.table("data/bully.txt", header = TRUE)

#�ݤ@�U��Ƶ��c�B�e�����B�򥻲έp�q
#�{������4.1
head(dta)
str(dta)
summary(dta)

#����C�֤k�P�C�֨k��ơA���O�ٰ� dta_f�Bdta_m
dta_f <- subset(dta, �ʧO == '�k')
dta_m <- subset(dta, �ʧO != '�k')

#�ݤ@�U�ܶ������p
#��4.2
require(GGally)
ggpairs(dta_f[,-1], axisLabels= 'internal')

#Baron & kenny�]1986�^ ���|�B�J�A�H�C�֤k�]dta_f�^�ܽd
#�{������4.2
summary(lm(�~�{~����+�~��,data=dta_f))
summary(m2<-lm(�Q�Q��~����+�~��,data=dta_f))
summary(lm(�~�{~�Q�Q��+�~��,data=dta_f))
summary(m4<-lm(�~�{~����+�Q�Q��+�~��,data=dta_f))

#�⵲�G�O�U�ӡA���@�U�n��
res_f <- lapply(list(m2, m4), summary)

#�����ݮt�ϡA���]�w�@�i�Ϥ����T�p��
#��4.3
par(mfrow = c(1, 3))
termplot(m4, partial.resid = T, smooth = panel.smooth) 


#Sobel test
#�^���^�j�k�Y�ƻP�зǻ~
a <- c(Est = res_f[[1]]$coef['����', 'Estimate'], 
       SE = res_f[[1]]$coef['����', 'Std. Error'])
b <- c(Est = res_f[[2]]$coef['�Q�Q��', 'Estimate'], 
       SE = res_f[[2]]$coef['�Q�Q��', 'Std. Error'])

#�p�⤤���ĪG�P�зǻ~�A�öi������
ab <- a['Est'] * b['Est']
abse <- sqrt(a['Est']^2 * b['SE']^2 + b['Est']^2 * a['SE']^2)
c(ab, z_ab = ab/abse, pz_ab = 2 * (1 - pnorm(abs(ab/abse))))


#�Q�Ω޹u�k�p�⤤���ĪG�H��϶�
#�����J alr3 �M��A�ΨӨ�U�޹u�k
require(alr3)

#�O�o���䪺�H���ؤl�n�]�w���@�� 
set.seed(2014)
beta4_bt <- bootCase(m4, B = 1001)
set.seed(2014)
beta2_bt <- bootCase(m2, B = 1001)

#�^�������ĪG
ab_bt <- beta4_bt[,3] * beta2_bt[,2]
c("Bootstrap SD" = sd(ab_bt), quantile(ab_bt, c(.025, .975)))


#�p�G�S���@�ܶq�A�i�H��MBESS�M��
require(MBESS)
mediation(dv=dta$�~�{, x=dta$����, mediator=dta$�Q�Q��,
  bootstrap = TRUE, B = 1001)
#�����ĪG�P�`�ĪG��
#��4.4
mediation.effect.plot(dv=dta$�~�{, x=dta$����, mediator=dta$�Q�Q��, 
                      legend.loc=NA, ylab = '�~�{', xlab = '�Q�Q��')


#�ո`�ĪG
#���ҩʧO����ƨ�Q�Q��v�T�O���ո`�ĪG
m1_fl <- lm(�Q�Q�� ~ ���� + �~�� + �ʧO + ����:�ʧO, data = dta)
m1_rd <- update(m1_fl, . ~ . - ����:�ʧO)
anova(m1_rd, m1_fl)
summary(m1_fl)$r.sq - summary(m1_rd)$r.sq

#���ҩʧO����ƨ�~�{�v�T�O���ո`�ĪG
m4_fl <-lm(�~�{ ~ ���� + �Q�Q�� + �~�� + �ʧO + ����:�ʧO, 
            data = dta)           
m4_rd <- update(m4_fl, . ~ . - ����:�ʧO) 
anova(m4_rd, m4_fl)
summary(m4_fl)$r.sq - summary(m4_rd)$r.sq

#���ҩʧO��Q�Q���~�{�v�T�O���ո`�ĪG
m4_fl2 <- update(m4_rd, . ~ . + �Q�Q��:�ʧO)
anova(m4_rd, m4_fl2)
summary(m4_fl2)$r.sq - summary(m4_rd)$r.sq

#�p��۹�����q�t�� 
100*(summary(m4_fl2)$r.sq - summary(m4_rd)$r.sq)/summary(m4_fl2)$r.sq

#�e�{�j�k���G
#�{������4.3
summary(m4_fl2)

#�e�{�ܶ��ĪG�A���Jcoefplot�M��
require(coefplot)

#�O�U�]�w
old <- theme_set(theme_bw())

#�h���I�Z�B��ĪG�e�X��
#��4.5
coefplot(update(m4_fl2, . ~ . - 1)) + 
 labs(x = '���p��', y = '�j�k�Ѽ�', title = '') 
 

#�Q��fortify���O���ƥ[�i���G���A��K�e��
m4_fy <- fortify(m4_fl2)

#�椬�@�ι�
#��4.6
ggplot(data = m4_fy, aes(x = �Q�Q��, y = .fitted, shape = �ʧO, color = �ʧO )) + 
 geom_point(aes(x = �Q�Q��, y = �~�{, shape = �ʧO))+
 stat_smooth(method = 'lm', size = 1) +
 scale_x_continuous(breaks = 0:12) +
 labs(x = '�Q�Q��', y = '�~�{') +
 theme(legend.position = c(.8, .1))
 
#�^�Ц�m�D�D
theme_set(old)

#����ո`�ĪG
#���M�󤣤䴩����A���ܶ������^��
require(pequod)
dtaeng <- dta
names(dtaeng) <- c('gender','dep','bully','BMI','age')
dtaeng$gender <- as.numeric(dtaeng$gender=="�k")
summary(rslt <- lmres(dep~BMI+age+bully*gender, data=dtaeng))
#�p��P����²��ײv
#�{������4.4
summary(sl<-simpleSlope(rslt,pred="bully",mod1="gender",coded="gender"))

#�]�i�H�e��
#��4.7
PlotSlope(sl)
