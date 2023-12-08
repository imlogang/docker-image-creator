FROM cimg/android:2023.12
USER circleci
LABEL com.circleci.preserve-entrypoint=true
ENTRYPOINT [ "/sbin/init", "--log-level=err" ]
