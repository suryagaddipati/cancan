for i in {1..500}; do sleep 0; echo -e   abcd "\033[31mRed\033[0m" $RANDOM; done
