from sec_edgar_downloader import Downloader
import re

class SEC8KMonitor:
    def __init__(self, tickers):
        self.dl = Downloader("quant_ai")
        self.ticker_pattern = re.compile(r'\b(?:' + '|'.join(tickers) + r')\b', re.I)
        
    def process_filing(self, filing):
        text = self._clean_html(filing.text)
        matches = self.ticker_pattern.findall(text)
        return {
            'filing_date': filing.date,
            'mentioned_tickers': list(set(matches)),
            'sentiment': self._calculate_sentiment(text)
        }
    
    def _calculate_sentiment(self, text):
        from transformers import pipeline
        sentiment = pipeline("text-classification", model="ProsusAI/finbert")
        return sentiment(text[:512])[0]['label']