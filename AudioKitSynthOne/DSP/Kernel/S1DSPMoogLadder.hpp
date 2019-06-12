// Based on implementation in CSound5 (LGPLv2.1)
// https://github.com/csound/csound/blob/develop/COPYING

#pragma once

#define MOOG_PI        3.14159265358979323846264338327950288

class S1DSPMoogLadder
{
 
  /* John ffitch tanh function to speed up inner loop */

  static double my_tanh(double x)
  {
    /* use the fact that tanh(-x) = - tanh(x)
     and if x>~4 tanh is approx constant 1
     and for small x tanh(x) =~ x
     So giving a cheap approximation */
    int sign = 1;
    if (x<0) {
      sign=-1;
      x= -x;
    }
    if (x>=4.0) {
      return sign;
    }
    if (x<0.5) return x*sign;
    return sign*tanh(x);
  }

public:
  S1DSPMoogLadder(float sampleRate) :
    sampleRate(sampleRate), thermal(0.000025)
  {
    memset(stage, 0, sizeof(stage));
    memset(delay, 0, sizeof(delay));
    memset(stageTanh, 0, sizeof(stageTanh));
    setCutoff(1000.0f);
    setResonance(0.10f);
  }
  
  S1DSPMoogLadder()
  {
    
  }
  
  float process(float sample)
  {
      // Oversample
      for (int j = 0; j < 2; j++)
      {
        float input = sample - resQuad * delay[5];
        delay[0] = stage[0] = delay[0] + tune * (my_tanh(input * thermal) - stageTanh[0]);
        for (int k = 1; k < 4; k++)
        {
          input = stage[k-1];
          stage[k] = delay[k] + tune * ((stageTanh[k-1] = my_tanh(input * thermal)) - (k != 3 ? stageTanh[k] : my_tanh(delay[k] * thermal)));
          delay[k] = stage[k];
        }
        // 0.5 sample delay for phase compensation
        delay[5] = (stage[3] + delay[4]) * 0.5;
        delay[4] = stage[3];
      }
      return delay[5];
  }
  
  void setResonance(float r)
  {
    if (resonance == r) {
        return;
    }
    resonance = r;
    resQuad = 4.0 * resonance * acr;
  }
  
  void setCutoff(float c)
  {
    if (cutoff == c) {
        return;
    }
    cutoff = c;
    
    double fc =  cutoff / sampleRate;
    double f  =  fc * 0.5; // oversampled
    double fc2 = fc * fc;
    double fc3 = fc * fc * fc;
    
    double fcr = 1.8730 * fc3 + 0.4955 * fc2 - 0.6490 * fc + 0.9988;
    acr = -3.9364 * fc2 + 1.8409 * fc + 0.9968;
    
    tune = (1.0 - exp(-((2 * MOOG_PI) * f * fcr))) / thermal;
    
    setResonance(resonance);
  }
  
private:
  double stage[4];
  double stageTanh[3];
  double delay[6];
  float cutoff;
  float resonance;
  float sampleRate;
  
  double thermal;
  double tune;
  double acr;
  double resQuad;
};
