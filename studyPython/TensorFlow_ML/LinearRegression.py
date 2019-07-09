# ----------------------------
# 선형회귀(Linear Regression)
# ----------------------------

# "가설"
# H(x) = Wx + b
# 가설(x) = 기울기x + y절편

# 기울기와 y절편값을 수정해나가면서 적합한 함수를 찾는 것
# 즉, 선형 회귀란 주어진 데이터를 이용해 일차방정식을 수정해가는 것
# - 학습을 거쳐서 가장 합리적인 선을 찾아내는 것
# - 학습을 많이 해도 완벽한 식을 찾아내지 못할 수 있습니다.
# - 하지만 실제 사례에서는 근사값을 찾는 것 만으로도 충분할 때가 많습니다.
# - 알파고도 결과적으로는 근사값을 가정하는 프로그램에 불과합니다.

# ---------------------------
# 비용 (Cost)
# ---------------------------

# "예측치와 실제값과의 거리"
# = ()(예측 값 - 실제 값)의 제곱) 의 평균


# ---------------------------
# 경사하강(Grandient Descent)
# ---------------------------

# 핵심은 "점프를 얼마나 뛰어야 하는가?"
# 너무 작게 점프하거나
# 너무 크게 점프하면
# 안된다.

# 1)tensorflow import
import tensorflow as tf

# x,y축 데이터 마련
xData = [1,2,3,4,5,6,7]
yData = [25000,55000,75000,110000,128000,155000,180000]

# 가설의 기울기 (weight)
# Y절편(b) 절편 (bias)
# random_uniform : -100~100 사이의 값을 렌덤하게
W = tf.Variable(tf.random_uniform([1],-100,100))
b = tf.Variable(tf.random_uniform([1],-100,100))

# X,Y를 플래이스홀더로서 정의해줌
X = tf.placeholder(tf.float32)
Y = tf.placeholder(tf.float32)

# 가설정의
H = W * X + b

# 비용(cost) 정의
# square : 제곱
# H - Y = 예측값 - 실제값
# reduce_mean 평균값을 구하는 것
cost = tf.reduce_mean(tf.square(H - Y))

# 경사하강 알고리즘에서 점프를 할 스텝의 거리를 정의
# GradientDescentOptimizer : 경사하강 라이브러리
a = tf.Variable(0.01)
optimizer = tf.train.GradientDescentOptimizer(a)
# 비용함수를 최소화시켜주는 방향으로 학습하도록 정의
train = optimizer.minimize(cost)
# 변수초기화
init = tf.global_variables_initializer()
# 세션정의
sess = tf.Session()
# 세션초기화
sess.run(init)

# 5000번 수행 할수 있도록
for i in range(5001) :
    # 학습시작
    sess.run(train,feed_dict={X:xData, Y:yData})
    # 500번에 한번찍 과정을 보여주도록 만들기
    if i % 500 == 0 :
        print(i, sess.run(cost, feed_dict={X: xData, Y: yData}),sess.run(W),sess.run(b))

# 8시간 일했을때의 값
print(sess.run(H, feed_dict={X:[8]}))
