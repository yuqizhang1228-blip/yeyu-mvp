// src/hooks/useCBTFlow.ts
// ==========================================
// CBT 5步流程控制 Hook
// ==========================================

import { useState, useCallback } from 'react';
import type { CBTStep } from '../types';

interface CBTState {
  step: CBTStep;
  situation?: string;
  automaticThought?: string;
  emotion?: string;
  emotionIntensity?: number;
  newPerspective?: string;
  microAction?: string;
}

export const useCBTFlow = () => {
  const [state, setState] = useState<CBTState>({
    step: 1,
  });

  const goToStep = useCallback((step: CBTStep) => {
    setState(prev => ({ ...prev, step }));
  }, []);

  const setSituation = useCallback((situation: string) => {
    setState(prev => ({ ...prev, situation, step: 2 }));
  }, []);

  const setAutomaticThought = useCallback((automaticThought: string) => {
    setState(prev => ({ ...prev, automaticThought, step: 3 }));
  }, []);

  const setEmotion = useCallback((emotion: string, intensity: number) => {
    setState(prev => ({ ...prev, emotion, emotionIntensity: intensity, step: 4 }));
  }, []);

  const setNewPerspective = useCallback((newPerspective: string) => {
    setState(prev => ({ ...prev, newPerspective, step: 5 }));
  }, []);

  const setMicroAction = useCallback((microAction: string) => {
    setState(prev => ({ ...prev, microAction }));
  }, []);

  const reset = useCallback(() => {
    setState({ step: 1 });
  }, []);

  return {
    ...state,
    goToStep,
    setSituation,
    setAutomaticThought,
    setEmotion,
    setNewPerspective,
    setMicroAction,
    reset,
  };
};

export default useCBTFlow;
