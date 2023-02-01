classdef bayopt
    properties
        X
        Y
    end
    properties (Hidden)
        model
    end
%     properties (SetAccess=private)
%         model
%     end
    methods
        function obj = bayopt(X,Y)
            if nargin > 0
                obj.X = X;
                obj.Y = Y;
                obj.model = fitrgp(X,Y);
            end
        end

        function [ypred,ysd] = surrogate(obj,Xnew)
            [ypred,ysd,~] = predict(obj.model,Xnew);

        end

        function probs = acquisition(obj,X,Xsamples)
            [yhat, ~] = surrogate(obj,X);
            best = max(yhat);
            [mu,std] = surrogate(obj,Xsamples);
            mu = mu(:,1);
            probs = cdf("Normal",(mu-best)/(std+1E-9));
        end

        function opt_samples = opt_acqusition(obj,X)
            Xsamples = rand(100,1);
            Xsamples = reshape(Xsamples,[numel(Xsamples),1]);
            scores = acquisition(obj,X,Xsamples);
            [~, max_ind] = max(scores);
            ix = X(max_ind);
            opt_samples = Xsamples(max_ind,1);
        end
        
    end
end