FROM cimg/android:2023.12
USER circleci
ENTRYPOINT [ "/sbin/init", "--log-level=err" ]
