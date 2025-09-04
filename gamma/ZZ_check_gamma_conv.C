R__LOAD_LIBRARY($WCSIM_BUILD_DIR/lib/libWCSimRoot.so)

#include "WCSimRootEvent.hh"
#include "WCSimEnumerations.hh"
#include "TChain.h"
#include "TVector3.h"
#include "TH1D.h"
#include "TStyle.h"
#include "TSystem.h"
#include "TF1.h"
#include "TLatex.h"
#include "TCanvas.h"
#include "TPad.h"
#include <iostream>

void ZZ_check_gamma_conv(const char * fname=nullptr, bool only0000=true)
{
    gStyle->SetOptStat(0);
    static TString fullpath;

    if (!fname) {
        const char * base = gSystem->Getenv("OUTPUT_PATH");
        if (!base) { std::cerr << "OUTPUT_PATH not set!" << std::endl; return; }
        if (only0000)
            fullpath = TString(base) + "/gamma/rootfiles/*0000.root";
        else
            fullpath = TString(base) + "/gamma/rootfiles/*.root";
    } else {
        fullpath = fname;
    }

    std::cout << "Adding files from: " << fullpath << std::endl;

    TChain *t = new TChain("wcsimT");
    t->Add(fullpath);

    Long64_t nEntries = t->GetEntries();
    std::cout << "Total entries in chain: " << nEntries << std::endl;
    if (nEntries == 0) return;

    WCSimRootEvent* wcsimrootsuperevent = new WCSimRootEvent();
    t->SetBranchAddress("wcsimrootevent",&wcsimrootsuperevent);

    WCSimRootTrigger* wcsimrootevent = nullptr;

    TH1D* hist_conv_dist = new TH1D("Conversion_distance","Conversion_distance",100,0,300);
    int count1pc = nEntries/100; if (count1pc==0) count1pc=1;

    for (Long64_t nev=0; nev<nEntries; ++nev)
    {
        if (nev % count1pc == 0) std::cout << "Running " << nev << " / " << nEntries << std::endl;

        t->GetEntry(nev);
        wcsimrootevent = wcsimrootsuperevent->GetTrigger(0);

        TVector3 startPos, stopPos;
        for (int i=0; i<wcsimrootevent->GetNtrack(); ++i)
        {
            WCSimRootTrack* trk = (WCSimRootTrack*)wcsimrootevent->GetTracks()->At(i);
            if (trk->GetId()==1)
            {
                startPos = TVector3(trk->GetStart(0),trk->GetStart(1),trk->GetStart(2));
                stopPos  = TVector3(trk->GetStop(0), trk->GetStop(1), trk->GetStop(2));
                break;
            }
        }

        double ene_electron = 0;
        double ene_positron = 0;
        for (int i=0; i<wcsimrootevent->GetNtrack(); ++i)
        {
            WCSimRootTrack* trk = (WCSimRootTrack*)wcsimrootevent->GetTracks()->At(i);
            if (abs(trk->GetIpnu())==11 && trk->GetParentId()==1 && trk->GetCreatorProcess()==kConv)
            {
                if (trk->GetIpnu()==11) ene_electron = trk->GetE();
                else ene_positron = trk->GetE();
            }
        }

        if (ene_electron+ene_positron > 0)
            hist_conv_dist->Fill((stopPos-startPos).Mag());
    }

    TString outdir = gSystem->DirName(fullpath);
    outdir = gSystem->DirName(outdir);
    outdir += "/checkconv";
    gSystem->mkdir(outdir, kTRUE);

    TString outpdf = outdir + (only0000 ? "/Conversion_distance_0000.pdf": "/Conversion_distance_all.pdf");
    
    double fitMin = 10.0;
    double fitMax = 300.0;
    TF1* fexp = new TF1("fexp","[0]*exp(-x/[1])",fitMin,fitMax);
    fexp->SetParameters(hist_conv_dist->GetMaximum(), 50.0);

    hist_conv_dist->GetXaxis()->SetTitle("Distance (cm)");
    hist_conv_dist->Draw();

    hist_conv_dist->Fit(fexp,"RQ"); 

    double A      = fexp->GetParameter(0);
    double lambda = fexp->GetParameter(1);
    double eA      = fexp->GetParError(0);
    double elambda = fexp->GetParError(1);

    TLatex lat;
    lat.SetNDC(true);
    lat.SetTextSize(0.04);
    lat.DrawLatex(0.55,0.85,Form("#lambda = %.2f #pm %.2f cm",lambda,elambda));
    lat.DrawLatex(0.55,0.79,Form("A = %.0f #pm %.0f",A,eA));

    gPad->SaveAs(outpdf);
    std::cout << "Saved to: " << outpdf << std::endl;
    
    t->Reset();
}
