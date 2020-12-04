#include <iostream>
#include <thread>
#include <chrono>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>

using namespace cv;

int main(const int argc, const char* argv[]) {

    Mat frame;
    Mat hsv;

    cv::VideoCapture cap;

    if(argc <= 1) {
        return 0;
    }

    cap.open(std::stoi(argv[1]));

    if(!cap.isOpened()) {
        std::cerr << "Cannot open camera device" << std::endl;
        return -1;
    }

    auto max_h_old = 0;

    while (true) {
        cap.read(frame);

        if(frame.empty()) {
            continue;
        }

        cvtColor(frame, hsv, COLOR_BGR2HSV);

        float h_ranges[] = {0, 180};
        float s_ranges[] = {0, 256};

        const float *ranges[] = {h_ranges, s_ranges};

        int histSize[] = {60, 64};
        int ch[] = {0, 1};

        Mat hist;
        calcHist(&hsv, 1, ch, noArray(), hist, 2, histSize, ranges, true);
        normalize(hist, hist, 0, 255, NORM_MINMAX);

        int scale = 5;
        Mat hist_frame(histSize[1] * scale, histSize[0] * scale, CV_8UC3);

        auto max_h = 0;
        auto max_s = 0;
        auto max_v = 0;

        for (int h = 0; h < histSize[0]; h++) {
            for (int s = 0; s < histSize[1]; s++) {
                float hist_val = hist.at<float>(h, s);
                if(max_v <= hist_val) {
                    max_v = hist_val;
                    max_s = s;
                    max_h = h;
                }

            }
        }

        cvtColor(hist_frame, hist_frame, COLOR_HSV2BGR);

        if(max_h_old != max_h) {
            std::cout << max_v << " " << max_s << " " << max_h << std::endl;
            max_h_old = max_h;
        }

        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    return 0;
}
