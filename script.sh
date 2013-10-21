for i in {1..50000}; do sleep 1000; echo -e   abcd "\033[31mRed\033[0m" $RANDOM; done
